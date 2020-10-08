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

  scope :name, -> (name) { where(name: name) }
end

class Gismo
  include Mongoid::Document
  field :name, type: String
  field :quantity, type: Integer 
  field :price, type: Float 
  embedded_in :user 

  scope :name, -> (name) { where(name: name)}
  scope :quantity, -> (quantity) { where(quantity: quantity)}
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
  # looks up lot where lots.seller == user.name
  belongs_to :user, foreign_key: 'seller', primary_key: 'name'

  scope :seller, -> (seller) { where(seller: seller)}
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
  # get user name params n=Naff 
  post '/users' do 
    @users = User.all
    @users = @users.send(:name, params[:n]) if params[:n]
    
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <names>
      #{@users.distinct(:name)}
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
  post '/lots' do
    @g, @q, @t = params[:g], params[:q], params[:t]
    @current_user = settings.current_user 
    if User.where(name: @current_user).distinct('gismos.name').include?(@g)
      @description_lot = "Lot: \n
        from: #{@current_user} \n
        gismo:  #{@g} \n
        quantity: #{@q} \n
        total:  #{@t}"
    end 
    # creat if save render xml
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <!-- Lot created success -->
    <g>#{@g}</g><q>#{@q}</q><t>#{@t}</t>
    <scope_gismo>
      #{@scope_gismo}
    </scope_gismo>
    <description>
      #{@description_lot}
    </description>"

  end


end
