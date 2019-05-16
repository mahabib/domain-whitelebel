Sequel.migration do
  up do
    create_table(:org_users) do
      primary_key :id
      foreign_key :orgid, :organizations
      foreign_key :userid, :users
      Time :created_at
      Time :updated_at
    end
  end

  down do
    drop_table(:org_users)
  end
end