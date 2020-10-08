# Welcome to game with Naff, Niff and Nuff!
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
###  Inspect setting
- http :3000/
###  Clean the database and create the initial data
- http :3000/refresh
###  All Users Info
- http :3000/api/v1/users
###  User info
- http :3000/api/vi/users/naff
###  Login (default Naff, can use Naff or Niff or Nuff)
- http -f POST :3000/login name=Nuff
###  Create Lot
- http -f POST :3000/api/v1/lots g=Lion q=5 t=40.00
###  Delete Lot
###  Add Lot to advertise list
###  All advertise lots
###  Pay a Gismo from User
