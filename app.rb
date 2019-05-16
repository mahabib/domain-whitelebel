require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
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
  use Rack::Session::Cookie, secret: ENV['RACK_SECRET'], key: ENV['RACK_SECRET_KEY']
  use Rack::Protection
  plugin :csrf
  plugin :head

	error do |e|
		puts e.class, e.message, e.backtrace
		# if request.xhr?
		# 	{
		# 		:success => false,
		# 		:error => e.message
		# 	}
		# else
		# 	view :content=>"<p><strong>Oops, an error occurred.</strong></p><p>#{e.message}</p>"
		# end
		e.message
	end

	not_found do
		'where did it go?'
	end

	route do |r|
		@host = request.host
		raise "Host should include '#{ENV['DOMAIN']}'" if !(@host.include? ENV["DOMAIN"])
		@subdomain = @host.split('.').count >= 3 ? @host.sub(".#{ENV['DOMAIN']}", '') : nil
		raise "Expecting a sudomain 'xxx.#{ENV['DOMAIN']}'" if !@subdomain

		@req_paths = request.path.split("/")
		@req_paths.shift # To remove first element which is empty

		@org = Organization.where(:subdomain=>@subdomain).first
		raise "We don't recognise this, '#{@subdomain}' subdomain." if !@org

		data = JSON.parse(request.body.read) rescue {}
		request.body.rewind

		if ENV['RACK_ENV'] == 'development'
			puts "\n#{Time.now}\n#{request.request_method} #{request.path}\nxhr #{request.xhr?}"
			puts "params\n#{params}"
			puts "data\n#{data}"
		end

		r.root do
			@org_dets = @org.values
			view 'orgs/detail'
		end

		r.on "register" do
      r.redirect '/' if session[:user]
      r.get do
        view 'auth/register'
      end

      r.post do
        User.register data
        {
          :success => true
        }
      end
    end # /login

		r.on "login" do
      r.redirect '/' if session[:user]
      r.get do
        view 'auth/login'
      end

      r.post do
        ret = User.login data
        session[:user] = ret[:user]
        {
          :success => true,
          :values => {:token=>ret[:token]}
        }
      end
    end # /login

    r.post "logout" do
      session.clear
      { :success=>true }
    end

		r.put "org" do
			@org.update_org(data)
			{
				:success => true
			}
		end

		r.on "users" do
			r.get do
				@org_users = @org.org_users.collect{|x| x.values.merge(:user=>x.user.values)}
				view 'org-users/index'
			end

			r.post do
				raise "Unauthorized acess!" if !session[:user]
				org_user = OrgUser.create_org_user(@org, data)
				{ :success=>true, :values=>org_user.values.merge(:user=>org_user.user.values) }
			end
		end # /users
	end


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
end # App