Sequel.migration do
  change do
    create_table(:organizations) do
      primary_key :id
      String :name, :null=>false
      String :subdomain, :unique=>true, :null=>false
      Text :description
      Time :created_at
      Time :updated_at
    end
  end
end