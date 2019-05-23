App.route("users") do |r|
  data = @data
  r.get do
    @org_users = @org.org_users.collect{|x| x.values.merge(:user=>x.user.values)}
    view 'org-users/index'
  end
end # /users