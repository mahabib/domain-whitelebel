begin
  require_relative '.env'
rescue LoadError
  abort "\n.env.rb file does not exist. Please add it.\n\n"
end

puts "\n=========================\nENV - #{ENV['RACK_ENV']}\n#{Time.now}\n=========================\n\n"

require_relative "app"
run App.app