require 'sequel'
DB = Sequel.sqlite("./db/#{ENV.fetch('RACK_ENV', 'development')}.db")
# create a db file called 'development'
# assign db connection to top-level db constant (convention when there is only one global DB)
