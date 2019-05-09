class User < Sequel::Model
  many_to_one :organization, :key=>:orgid

  def self.create_user(org, data)
    data = App.strip_and_squeeze(data)
    data = App.symbolize(data)
    raise "Name is required!" if !data[:name]
    raise "Email is required!" if !data[:name]
    raise "Email already exists!" if org.users_dataset.where(:email=>data[:email]).count > 0
    self.create(
      :orgid=>org.id,
      :name=>data[:name],
      :email=>data[:email],
      :gender=>data[:gender],
      :address=>data[:address]
    )
  end
end