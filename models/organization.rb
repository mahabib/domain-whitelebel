class Organization < Sequel::Model
  one_to_many :users, :key=>:orgid

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
end