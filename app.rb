require 'roda'
require 'tilt'
require 'slim'
require 'slim/include'

class App < Roda
  plugin :render, engine: 'slim', views: 'views'
  plugin :all_verbs
  plugin :not_found
  plugin :error_handler
  plugin :json
  plugin :static, ['/css', '/js', '/images'], root: 'public'

  error do |e|
    puts e.class, e.message, e.backtrace
    view :content=>"<p><strong>Oops, an error occurred.</strong></p><p>#{e.message}</p>"
  end

  not_found do
    'where did it go?'
  end

  route do |r|
    @host = request.host
    @domain = 'id.local'
    @subdomain = @host.split('.').count >= 3 ? @host.sub(".#{@domain}", '') : nil

    @valid_subdomains = ['demo', 'test']
    raise "We don't recognise this, '#{@subdomain}' subdomain." if @subdomain && !(@valid_subdomains.include? @subdomain)
    r.root do
      view 'index'
    end
  end
end