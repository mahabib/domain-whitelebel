require_relative 'db'
require 'sequel/model'

if ENV['RACK_ENV'] == 'development'
  Sequel::Model.cache_associations = false
end

Sequel::Model.plugin :auto_validations
Sequel::Model.plugin :prepared_statements

require_relative 'models/organization'
require_relative 'models/user'