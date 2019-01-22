class AddCompanyNameToSignedupUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :signedup_users, :company_name, :string
  end
end