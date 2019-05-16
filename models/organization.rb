class Organization < Sequel::Model
  one_to_many :org_users, :key=>:orgid

  def self.create_organization(data)
    data = App.strip_and_squeeze(data)
    data = App.symbolize(data)
    raise "Name is required!" if !data[:name]
    subdomain = App.slug(data[:name])
    raise "Name already exists!" if Organization.where(:subdomain=>subdomain).count > 0
    self.create(
      :name=>data[:name],
      :subdomain=>subdomain,
      :description=>data[:description]
    )
  end

  def update_org(data)
    data = App.strip_and_squeeze(data)
    data = App.symbolize(data)
    raise "Name is required!" if !data[:name]
    raise "Name already exists!" if Organization.exclude(:id=>id).where(:name=>data[:name]).count > 0
    update(
      :name=>data[:name],
      :description=>data[:description]
    )
  end
end