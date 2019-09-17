class AddDefaultCompanyIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :default_company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end
