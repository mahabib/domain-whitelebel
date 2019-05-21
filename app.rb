require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'slim/include'

require_relative 'models'

class App < Roda
  plugin :placeholder_string_matchers
  plugin :indifferent_params
  plugin :all_verbs
  plugin :not_found
  plugin :error_handler
  plugin :json
  plugin :render, engine: 'slim', views: 'views'
  plugin :static, ['/css', '/js', '/images', '/lib'], root: 'public'
  use Rack::Session::Cookie, secret: ENV['RACK_SECRET'], key: ENV['RACK_SECRET_KEY']
  plugin :chunked, chunk_by_default: true
  # If you use :chunk_by_default, but want to turn off chunking for a view, call no_chunk!
  use Rack::Protection
  plugin :route_csrf
  plugin :multi_route

  require_relative './routes/common'
  require_relative './routes/main'
  require_relative './routes/org'


  error do |e|
    puts e.class, e.message, e.backtrace
    # if request.xhr?
		# 	{
		# 		:success => false,
		# 		:error => e.message
		# 	}
		# else
    #   view :content=>"<p><strong>Oops, an error occurred.</strong></p><p>#{e.message}</p>"
		# end
    e.message
  end

  not_found do
    'where did it go?'
  end

  route do |r|
    @data = data = JSON.parse(request.body.read) rescue {}
	  request.body.rewind

    @req_path = request.path
    @req_paths = @req_path.split("/")
	  @req_paths.shift # To remove first element which is empty

    if ENV['RACK_ENV'] == 'development'
  	  puts "\n#{Time.now}\n#{request.request_method} #{request.path}\nxhr #{request.xhr?}"
  	  puts "params\n#{params}"
  	  puts "data\n#{data}"
      puts "env['HTTP_ACCEPT']\n#{env['HTTP_ACCEPT']}"
  	end

    @user = session[:user] ? User.where(:email=>session[:user]).first : nil

    @host = request.host
    @subdomain = nil
    @special_org = false
    if (@host.split('.').last(2).join('.') == ENV['DOMAIN'])
      @subdomain = @host.sub(".#{ENV['DOMAIN']}", '') if @host.split('.').count >= 3
      if @subdomain
        @org = Organization.where(:subdomain=>@subdomain).first
        raise "We don't recognise this, '#{@subdomain}' subdomain." if !@org
        r.root do
          @org_dets = @org.get_dets(@user)
          view 'orgs/detail'
        end
      else
        r.root do
          view 'index'
        end
      end
    else # special-org
      @org = Organization.where(:domain=>@host).first
      raise "We don't recognise this, '#{@host}'." if !@org
      @special_org = true
      r.root do
        @org_dets = @org.get_dets(@user)
        view 'orgs/detail'
      end
    end

    r.multi_route
  end # /route



  # Helpers
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

  def self.check_access main, subdomain, special_org
    if main
      raise "Unauthorized acces!" if subdomain || special_org
    else
      raise "Unauthorized acces!" if !subdomain || !special_org
    end
  end
end # App