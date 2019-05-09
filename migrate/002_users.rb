Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      foreign_key :orgid, :organizations
      String :name, :null=>false
      String :email, :unique=>true, :null=>false
      String :gender, :null=>false
      Text :address
      String :contact_no
      Time :created_at
      Time :updated_at
    end
  end

  down do
    drop_table(:users)
  end
end