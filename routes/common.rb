App.route("register") do |r|
  data = @data
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

App.route("login") do |r|
  data = @data
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

App.route("logout") do |r|
  data = @data
  r.post do
    session.clear
    { :success=>true }
  end
end

App.route("api") do |r|
  data = @data
  r.on "orgs" do
    r.on String do |subdomain|
      @org = Organization.where(:subdomain=>subdomain).first
      raise "Invalid organization!" if !@org
      @org_dets = @org.get_dets(@user)

      r.post "users" do
        raise "Unauthorized acess!" if !@user
        OrgUser.create_or_remove_org_user(@org, @user)
        { :success=>true }
      end

      r.put do
        raise "Unauthorized acess!" if !@user
        @org.update_org(data)
        {
          :success => true
        }
      end
    end # /api/orgs/:subdomain
  end # /api/orgs
end