class AddGroupIdToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :group_id, :integer, references: "CompanyGroup", foreign_key: true, index: true
  end
end