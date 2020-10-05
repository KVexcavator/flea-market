require 'sinatra'
require 'sinatra/reloader' if development?
require 'mongoid'

# DB setup
Mongoid.load!(File.join(File.dirname(__FILE__), 'config', 'mongoid.yml'))

# Configuration
configure :development do
  # ...
end

# Models

# Endpoints
get '/' do
  'Welcome to Flea-market!'
end
