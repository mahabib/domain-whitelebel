require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'slim/include'

require_relative 'models'

class App < Roda
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

  require_relative './helpers'
  require_relative './routes/common'
  require_relative './routes/main'
  require_relative './routes/org'

  error do |e|
    puts e.class, e.message, e.backtrace
    # if request.xhr?
		# 	{ :success => false, :error => e.message }
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

    if ENV['RACK_ENV'] == 'development'
  	  puts "\n#{Time.now}\n#{request.request_method} #{request.path}\nxhr #{request.xhr?}"
  	  puts "params\n#{params}"
  	  puts "data\n#{data}"
      puts "env['HTTP_ACCEPT']\n#{env['HTTP_ACCEPT']}"
  	end

    @host = request.host
    @subdomain = nil
    @special_org = false

    if (@host.split('.').last(2).join('.') == ENV['DOMAIN'])
      @subdomain = @host.sub(".#{ENV['DOMAIN']}", '') if @host.split('.').count >= 3
      if @subdomain
        @org = Organization.where(:subdomain=>@subdomain).first
        raise "We don't recognise this, '#{@subdomain}' subdomain." if !@org
      end
    else # special-org
      @org = Organization.where(:domain=>@host).first
      raise "We don't recognise this, '#{@host}'." if !@org
      @special_org = true
    end

    @user = session[:user] ? User.where(:email=>session[:user]).first : nil

    # ROUTES
    r.on "register" do r.route("register") end
    r.on "login" do r.route("login") end
    r.on "logout" do r.route("logout") end
    r.on "api" do r.route("api") end
    
    if @subdomain || @special_org
      r.root do
        @org_dets = @org.get_dets(@user)
        view 'orgs/detail'
      end
      r.on "org" do r.route("org") end
      r.on "users" do r.route("users") end
    else
      r.root do
        view 'index'
      end
      r.on "all-users" do r.route("all-users") end
      r.on "orgs" do r.route("orgs") end
      r.on "passion" do r.route("passion") end
    end
  end # /route
end # App