App.route("org") do |r|
  App.check_access(false, @subdomain, @special_org)
  data = @data
  r.put do
    @org.update_org(data)
    {
      :success => true
    }
  end
end

App.route("users") do |r|
  App.check_access(false, @subdomain, @special_org)
  data = @data
  r.get do
    @org_users = @org.org_users.collect{|x| x.values.merge(:user=>x.user.values)}
    view 'org-users/index'
  end

  r.post do
    raise "Unauthorized acess!" if !@user
    OrgUser.create_or_remove_org_user(@org, @user)
    { :success=>true }
  end
end # /users