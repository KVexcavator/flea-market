## Version
- ruby-2.7.0 Ubuntu 18.04
## Prepare project
- bundle
- sudo systemctl status mongodb
- sudo systemctl start mongodb
- ruby app.rb -e development/production/test
## Apply 
- bundle exec ruby app.rb
- localhost:3000
## httpie
# Inspect setting
- http :3000/
# Clean the database and create the initial data
- http :3000/refresh
