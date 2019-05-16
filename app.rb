require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'slim/include'

require_relative 'models'

class App < Roda
  plugin :placeholder_string_matchers
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
    #   view :content=>"<p><strong>Oops, an error occurred.</strong></p><p>#{e.message}</p>"
		# end
    e.message
  end

  not_found do
    'where did it go?'
  end

  route do |r|
    data = JSON.parse(request.body.read) rescue {}
	  request.body.rewind

    @req_paths = request.path.split("/")
	  @req_paths.shift # To remove first element which is empty

    if ENV['RACK_ENV'] == 'development'
  	  puts "\n#{Time.now}\n#{request.request_method} #{request.path}\nxhr #{request.xhr?}"
  	  puts "params\n#{params}"
  	  puts "data\n#{data}"
  	end

    @user = session[:user] ? User.where(:email=>session[:user]).first : nil

    r.root do
      view 'index'
    end

    r.on "register" do
      r.redirect '/' if @user
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
      r.redirect '/' if @user
      r.get do
        view 'auth/login'
      end

      r.post do
        ret = User.login data
        session[:user] = ret[:user][:email]
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

    r.on "users" do
      r.get do
        @users = User.collect{|x| x.values}
        view 'users/index'
      end
    end # /users

    r.on "orgs" do
      r.on ":subdomain" do |subdomain|
        @org = Organization.where(:subdomain=>subdomain).first
        raise "Invalid organization!" if !@org
        @org_dets = @org.get_dets(@user)

        r.on "users" do
          r.get do
            @org_users = @org.org_users.collect{|x| x.values.merge(:user=>x.user.values)}
            view 'org-users/index'
          end

          r.post do
            raise "Unauthorized acess!" if !@user
            OrgUser.create_or_remove_org_user(@org, @user)
            { :success=>true }
          end
        end # /orgs/:org_id/users

        r.put do
          raise "Unauthorized acess!" if !@user
          @org.update_org(data)
          {
            :success => true
          }
        end
        
        r.get do
          view 'orgs/detail'
        end
      end # /orgs/:org_id

      r.get do
        @orgs = Organization.collect{|x| x.values}
        view 'orgs/index'
      end

      r.post do
        raise "Unauthorized acess!" if !@user
        org = Organization.create_organization(data)
        { :success=>true, :values=>org.values }
      end
    end # /orgs
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
end # App