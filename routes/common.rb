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