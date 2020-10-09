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
  field :quantity, type: Integer 
  field :price, type: Float 
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
  # player = Player.find_ny(name: "Naff")
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
  @test =  Player.all 
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <test>
    #{@test.to_json}
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

  # get all players array niks 
  get '/players' do 
    @players = Player.all.distinct(:nik)
    
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <niks>
      #{@players}
    </niks>"
  end

  # get lots
  get '/lots' do
    @lots = Lot.all.pluck(:description, :total) 
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
    @gismo_quantity = Player.current
      .pluck("gismos.title", "gismos.quantity")
      .first.first.map {|l| l.to_h}
      .select {|l| l["title"] == @g }  
      .first["quantity"].to_i

    # validate title and quantity
    # update date gismos
    # create  and render lot 
    if Player.current.distinct('gismos.title').include?(@g) and @q <= @gismo_quantity
      @description_lot = "Lot: from:#{@current_user}, gismos:#{@g}, quantity:#{@q}"

      @gismo_quantity -= @q
      Player.current
        .where(gismos: {"gismos.title": @g})
        .update("gismos.quantity": @gismo_quantity)
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


end
