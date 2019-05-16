class OrgUser < Sequel::Model
  many_to_one :organization, :key=>:orgid
  many_to_one :user, :key=>:userid

  def self.create_or_remove_org_user(org, usr)
    org_user = org.org_users_dataset.where(:userid=>usr.id).first
    if org_user
      org_user.delete
    else
      org_user = self.create(
        :orgid=>org.id,
        :userid=>usr.id
      )
    end
  end
end