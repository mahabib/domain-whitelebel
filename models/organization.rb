class Organization < Sequel::Model
  one_to_many :org_users, :key=>:orgid

  def self.create_organization(data)
    data = Helpers.strip_and_squeeze(data)
    data = Helpers.symbolize(data)
    raise "Name is required!" if !data[:name]
    subdomain = Helpers.slug(data[:name])
    raise "Name already exists!" if Organization.where(:subdomain=>subdomain).count > 0
    self.create(
      :name=>data[:name],
      :subdomain=>subdomain,
      :description=>data[:description]
    )
  end

  def update_org(data)
    data = Helpers.strip_and_squeeze(data)
    data = Helpers.symbolize(data)
    raise "Name is required!" if !data[:name]
    raise "Name already exists!" if Organization.exclude(:id=>id).where(:name=>data[:name]).count > 0
    update(
      :name=>data[:name],
      :description=>data[:description]
    )
  end

  def get_dets usr=nil
    ret = self.values.merge(:following=>false)
    ret[:following] = true if usr && org_users_dataset.where(:userid=>usr.id).count > 0
    ret
  end
end