require 'sinatra'
require 'sinatra/reloader' if development?
require 'mongoid'

# DB setup
Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

# Configuration
configure :development do
  enable :sessions
  # settings.name
  set :port, 3000
  set :max_lots, 10
  set :advertising_fee, 100.00
end

# Models
class User
  include Mongoid::Document 
  field :name, type: String
  field :purse, type: Float 
  embeds_many :gismos, dependent: :delete_all
  has_many :lots, foreign_key: 'user_ref', primary_key: 'name'

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
  field :discription, type: String
  field :price, type: Float 
  embedded_in :user 
end

class Lot
  include Mongoid::Document
  field :user_ref, type: String 
  field :name, type: String 
  field :quantity, type: Integer
  field :total, type: Float 
  # if true user.purse - settings.advertising_fee
  field :advertised, type: Boolean, default: false 
  # user = User.find(id)
  # user.lots 
  belongs_to :user, foreign_key: 'user_ref', primary_key: 'name'
end

# Endpoints
get '/' do
  "Port: #{settings.port}, Max lots: #{settings.max_lots}, Advertising fee: #{settings.advertising_fee}"
end
