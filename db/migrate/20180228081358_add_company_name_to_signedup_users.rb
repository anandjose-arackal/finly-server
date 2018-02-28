class AddCompanyNameToSignedupUsers < ActiveRecord::Migration
  def change
    add_column :signedup_users, :company_name, :string
  end
end