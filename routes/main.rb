App.route("all-users") do |r|
  App.check_access(true, @subdomain, @special_org)
  data = @data
  r.get do
    @users = User.collect{|x| x.values}
    view 'users/index'
  end
end # /users

App.route("orgs") do |r|
  App.check_access(true, @subdomain, @special_org)
  data = @data
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

App.route("passion") do |r|
  if !App.accessible(true, @subdomain, @special_org)
    response.status = 404
    response['Content-Type'] = 'text/html'
    response.write("Where did it go?")
  end

  r.get do
    "Passion"
  end
end