require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader' if development?
require 'byebug' if development? # byebug
require 'mongoid'
require 'bson'
require 'bson/active_support'

# DB setup
Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

# Configuration
configure :development do
  #enable :sessions
  # settings.name
  set :current_user, "Naff"
  @@current = settings.current_user
  set :port, 3000
  set :max_lots, 10
  set :advertising_fee, 100.00
end

# Models
class Player
  include Mongoid::Document 
  field :nik, type: String
  field :purse, type: Float 
  embeds_many :gismos
  has_many :lots, foreign_key: 'seller', primary_key: 'nik'

  def self.current
    where(nik: @@current)
  end
end

class Gismo
  include Mongoid::Document
  field :title, type: String
  field :quantity, type: Integer, default: 0 
  field :price, type: Float, default: 50.00 
  embedded_in :player
end

class Lot
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  field :seller, type: String 
  # dynamically generated
  field :description, type: String 
  field :total, type: Float 
  # if true user.purse - settings.advertising_fee
  field :advertised, type: Boolean, default: false 
  # player = Player.find_by(name: "Naff")
  # player.lots 
  # looks up lot where lots.seller == player.nik 
  belongs_to :player, foreign_key: 'seller', primary_key: 'nik'
  
  def self.advertised
    where(advertised: true)
  end

  scope :seller, -> (seller) { where(seller: seller)}
  scope :total, -> (total) { where(total: total) }
end

# Endpoints
# Inspect setting 
get '/' do
  "Port: #{settings.port}, Max lots: #{settings.max_lots}, Advertising fee: #{settings.advertising_fee}, Current User: #{settings.current_user}"
end

# Clean the database and create the initial data
get '/refresh' do
  load './seed.rb'
  'Refresh success!'
end

# test model methods
get '/test' do
  #@test = Player.current.first.gismos.where(title: "Elephant").first.quantity.class 
  #@test =  Player.current.first.attributes
  @test = Player.all.to_json 

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <test>
    #{@test}
  </test>"
end

# login name=[Naff,Niff,Nuff], default-Naff
post '/login' do
  settings.current_user = params[:nik]
  "Success Login: #{settings.current_user}!"
end

namespace '/api/v1' do

  before do
    content_type 'text/xml'
  end

  helpers do
  
    def niks_all 
      t = []
      Player.each {|p| t << p.nik}
      t
    end 

    def lots_descriptions_all
      t = []
      Lot.each {|d| t << d.description}
      t
    end

    def get_ids_lots(title)
      ids = []
      lots_descriptions_all.select{|d| d.include? title}.each do |d|
        s = []
        s << Lot.where(description: d).first 
        s.compact.each do |lot|
          ids << lot.id.to_s
        end
      end 
      ids
    end

  end

  # players array 
  get '/players' do 
    @players = niks_all 
    
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <niks>
      #{@players}
    </niks>"
  end

  # get lots
  get '/lots' do
    @lots = Lot.all.pluck(:description, :total, :advertised) 
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <lots>
      #{@lots}
    </lots>"
  end

  # get player info by nik 
  get '/players/:nik' do
    @nik = params[:nik].capitalize 
    @player = Player.current 
    @purse = @player.distinct(:purse).first
    @gismos = @player.distinct(:gismos).to_json

    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <nik>
      #{@nik}
    </nik>
    <purse>
      #{@purse}
    </purse>
    <gismos>
      #{@gismos}
    </gismos>"
  end

  # create lot, params - g=gismo, q=quantity, t=total 
  post '/lot' do
    @g, @q, @t = params[:g], params[:q].to_i, params[:t].to_f
    @current_user = settings.current_user
    @reserve = @test = Player.current.first.gismos.where(title: @g).first.quantity

    # validate title and quantity
    # update date gismos
    # create  and render lot 
    if Player.current.distinct('gismos.title').include?(@g) and @q <= @reserve
      @description_lot = "Gismos: #{@g} quantity: #{@q}"

      @reserve -= @q
      Player.current.first.gismos.where(title: @g).update(quantity: @reserve)
      Lot.create!(seller: @current_user, description: @description_lot, total: @t)

      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <!-- Lot created success -->
      <description>
        #{@description_lot}
      </description>
      <total>
        #{@t}
      </total>"
    else
      "Lot not create"
    end 

  end

  # loock up a lot  by gismo title 
  # return arrays id
  get '/bargain/:title' do

    @ids_lots = get_ids_lots(params[:title].capitalize)

    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <!-- Result id-->
    <lots>
      #{@ids_lots}
    </lots>"

  end

  # buy lot
  post '/bargain/lots/:id' do
    
    lot = Lot.find(params[:id])
    seller = lot.seller 
    seller_purse = Player.where(nik: seller).first.purse  
    total = lot.total
    purse = Player.current.first.purse 
    if @@current == seller or purse < total
      raise "Transaction not available" 
    end
    lot.update(seller: @@current) 
    seller_purse += total 
    purse -= total 
    Player.current.first.update(purse: purse)
    Player.where(nik: seller).first.update(purse: seller_purse)

    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <!--Success-->"
  end

end
