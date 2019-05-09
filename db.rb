require 'sequel/core'

puts "DB_URL: #{ENV['DB_URL']}"
# DB = Sequel.sqlite('./domain-whitelable.db')
DB = Sequel.connect(ENV['DB_URL'])