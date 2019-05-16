class OrgUser < Sequel::Model
  many_to_one :organization, :key=>:orgid
  many_to_one :user, :key=>:userid

  def self.create_org_user(org, data)
    data = App.strip_and_squeeze(data)
    data = App.symbolize(data)
    raise "Email is required!" if !data[:email] || data[:email] == ""
    usr = User.where(:email=>data[:email]).first
    raise "User doesn't exist in the system!" if !usr
    org_user = org.org_users_dataset.where(:userid=>usr.id).first
    org_user = self.create(
      :orgid=>org.id,
      :userid=>usr.id
    ) if !org_user
    org_user
  end
end