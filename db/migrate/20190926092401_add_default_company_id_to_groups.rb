class AddDefaultCompanyIdToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :company_groups, :default_company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end
