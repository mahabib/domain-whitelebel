class User < Sequel::Model
  one_to_many :org_users, :key=>:userid

  def self.register(data)
    data = App.strip_and_squeeze(data)
    data = App.symbolize(data)
    raise "Name is required!" if !data[:name]
    raise "Email is required!" if !data[:name]
    raise "Email already exists!" if User.where(:email=>data[:email]).count > 0
    raise "Password is required!" if !data[:password]
    raise "Gender is required!" if !data[:gender]
    
    self.create(
      :name=>data[:name],
      :email=>data[:email],
      :password=>BCrypt::Password.create(data[:password]),
      :gender=>data[:gender],
      :contact_no=>data[:contact_no],
      :address=>data[:address]
    )
  end

  def self.login(data)
    data = App.strip_and_squeeze(data)
    data = App.symbolize(data)
    raise "Email is required!" if !data[:email] || data[:email] == ""
    raise "Password is required!" if !data[:password] || data[:password] == ""

    usr = User.where(:email=>data[:email]).first
    raise "User doesn't exist!" if !usr

    db_password = BCrypt::Password.new(usr.password)
    raise "Password doesn't match!" if(db_password != data[:password])

    exp = Time.now.to_i + 4 * 3600
    payload = {:user => usr.email, :exp => exp}
    token = JWT.encode payload, ENV['JWT_SECRET'], ENV['JWT_ALGO']
    {:user=>usr, :token=>token}
  end

  def self.is_login(token)
    verify = true
    login = true
    begin
      decoded_token = JWT.decode token, ENV['JWT_SECRET'], verify, { :algorithm => ENV['JWT_ALGO'] }
    rescue JWT::ExpiredSignature, JWT::VerificationError => e
      login = false
      puts "\n#{e.message}\n#{e.inspect}\n"
    else
      login = false
      puts "\n#{e.message}\n#{e.inspect}\n"
    end
    login
  end
end