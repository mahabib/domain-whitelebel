require 'roda'
require 'tilt'
require 'slim'
require 'slim/include'

require_relative 'models'

class App < Roda
  plugin :indifferent_params
  plugin :render, engine: 'slim', views: 'views'
  plugin :all_verbs
  plugin :not_found
  plugin :error_handler
  plugin :json
  plugin :static, ['/css', '/js', '/images', '/lib'], root: 'public'

  error do |e|
    puts e.class, e.message, e.backtrace
    if request.xhr?
			{
				:success => false,
				:error => e.message
			}
		else
      view :content=>"<p><strong>Oops, an error occurred.</strong></p><p>#{e.message}</p>"
		end
  end

  not_found do
    'where did it go?'
  end

  route do |r|
    @host = request.host
    @domain = 'id.local'
    @subdomain = @host.split('.').count >= 3 ? @host.sub(".#{@domain}", '') : nil
    puts "@subdomain: #{@subdomain}"

    @valid_subdomains = ['demo', 'test']
    raise "We don't recognise this, '#{@subdomain}' subdomain." if @subdomain && !(@valid_subdomains.include? @subdomain)

    data = JSON.parse(request.body.read) rescue {}
	  request.body.rewind

    if ENV['RACK_ENV'] == 'development'
  	  puts "\n#{Time.now}"
  	  puts "#{request.request_method} #{request.path}"
  	  puts "xhr #{request.xhr?}"
  	  puts "params\n#{params}"
  	  puts "data\n#{data}"
  	end

    r.root do
      # view 'index'
      r.redirect '/users'
    end

    r.on "orgs" do
      r.get do
        @orgs = Organization.where(:subdomain=>@subdomain).collect{|x| x.values}
        view 'orgs/index'
      end

      r.post do
        org = Organization.create_organization(data)
        { :success=>true, :values=>org.values }
      end
    end # /orgs

    r.on "users" do
      @org = Organization.where(:subdomain=>@subdomain).first
      raise "Invalid organization" if !@org

      r.get do
        @users = @org.users.collect{|x| x.values}
        puts "@users"
        puts @users.inspect
        view 'users/index'
      end

      r.post do
        user = User.create_user(@org, data)
        { :success=>true, :values=>user.values }
      end
    end # /users
  end



  def self.symbolize(obj)
    return obj.reduce({}) do |memo, (k, v)|
      memo.tap { |m| m[k.to_sym] = symbolize(v) }
    end if obj.is_a? Hash
      
    return obj.reduce([]) do |memo, v| 
      memo << symbolize(v); memo
    end if obj.is_a? Array
    
    obj
  end

	def self.strip_and_squeeze(data)
		data.each do |key, val|
			if val.is_a? String
				data[key] = val.strip.squeeze(" ")
				data[key] = nil if data[key].empty?
			else
				data[key] = val
			end
		end
		data
	end
	
	def self.slug(text)
		text ? text.strip.downcase.split(/\W+/).join("-") : ""
	end
end