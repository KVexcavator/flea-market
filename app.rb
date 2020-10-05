require 'sinatra'
require 'sinatra/reloader' if development?
require 'mongoid'

# DB setup
Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

# Configuration
configure :development do
  # settings.name
  set :port, 3000
  set :max_lots, 10
  set :advertising_fee, 100.00
end

# Models

# Endpoints
get '/' do
  "Port: #{settings.port}, Max lots: #{settings.max_lots}, Advertising fee: #{settings.advertising_fee}"
end
