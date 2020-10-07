require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader' if development?
require 'mongoid'
require 'bson'
require 'bson/active_support'

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

namespace '/api/v1' do

  before do
    content_type 'text/xml'
  end

  # get all users to json
  get '/users' do
    @list = User.all.distinct(:name)
    
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <names>
      #{@list}
    </names>"
  end

  get '/users/:name' do
    @name = params[:name].capitalize 
    @user = User.where(name: @name )

    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <name>
      #{@name}
    </name>
    <json>
      #{@user.to_json}
    </json>"
  end

end
