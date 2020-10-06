require 'sinatra'
require 'sinatra/reloader' if development?
require 'mongoid'

# DB setup
Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

# Configuration
configure :development do
  #enable :sessions
  # settings.name
  set :port, 3000
  set :max_lots, 10
  set :advertising_fee, 100.00
end

# Models
class User
  include Mongoid::Document 
  field :id, type: String  
  field :_id, type: String, default: ->{ id }
  field :name, type: String
  field :purse, type: Float 
  embeds_many :gismos
  has_many :lots, foreign_key: 'seller', primary_key: 'name'

  # get '/login/:id'
  # session[:user_id] = params[:id]
  # User.find_by_session(session[:user_id])
  def self.find_by_session(id)
    where(id: id).first
  end
end

class Gismo
  include Mongoid::Document
  field :name, type: String
  field :_id, type: String, default: ->{ name }
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
  # if true user.purse - settings.advertising_fee
  field :advertised, type: Boolean, default: false 
  # user = User.find(id)
  # user.lots 
  # looks up emails where lots.seller == user.name
  belongs_to :user, foreign_key: 'seller', primary_key: 'name'
end

# Endpoints
# Inspect setting 
get '/' do
  "Port: #{settings.port}, Max lots: #{settings.max_lots}, Advertising fee: #{settings.advertising_fee}"
end

# Clean the database and create the initial data
get '/refresh' do
  load './seed.rb'
  'Refresh success!'
end
