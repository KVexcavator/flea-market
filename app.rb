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
  set :port, 3000
  set :max_lots, 10
  set :advertising_fee, 100.00
end

# Models
class User
  include Mongoid::Document 
  field :id, type: String  
  field :name, type: String
  field :purse, type: Float 
  embeds_many :gismos
  has_many :lots, foreign_key: 'seller', primary_key: 'name'

end

class Gismo
  include Mongoid::Document
  field :name, type: String
  field :quantity, type: Integer 
  field :price, type: Float 
  embedded_in :user 
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
  # user = User.find(id)
  # user.lots 
  # looks up lot where lots.seller == user.name
  belongs_to :user, foreign_key: 'seller', primary_key: 'name'

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

# login name=[Naff,Niff,Nuff], default-Naff
post '/login' do
  settings.current_user = params[:name]
  "Success Login: #{settings.current_user}!"
end

namespace '/api/v1' do

  before do
    content_type 'text/xml'
  end

  # get all users array names 
  get '/users' do 
    @users = User.all.distinct(:name)
    
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <names>
      #{@users}
    </names>"
  end

  # get lots
  get '/lots' do
    @lots = Lot.all.pluck(:description, :total) 
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <names>
      #{@lots}
    </names>"
  end

  # get user info by name
  get '/users/:name' do
    @name = params[:name].capitalize 
    @user = User.where(name: @name )
    @purse = @user.distinct(:purse).first
    @gismos = @user.distinct(:gismos).to_json

    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <name>
      #{@name}
    </name>
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
    @gismo_quantity = User.where(name: @current_user)
      .pluck("gismos.name", "gismos.quantity")
      .first.first.map {|l| l.to_h}
      .select {|l| l["name"] == @g }  
      .first["quantity"].to_i

    # validate gismo-name and quantity
    # update date gismos
    # create  and render lot 
    if User.where(name: @current_user).distinct('gismos.name').include?(@g) and @q <= @gismo_quantity
      @description_lot = "Lot: 
        from: #{@current_user}
        gismo:  #{@g}
        quantity: #{@q}"

      @gismo_quantity -= @q
      User.where(name: @current_user)
        .where(gismos: {"gismos.name": @g})
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
