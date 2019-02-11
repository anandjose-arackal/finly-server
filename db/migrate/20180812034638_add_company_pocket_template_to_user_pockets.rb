class AddCompanyPocketTemplateToUserPockets < ActiveRecord::Migration[4.2]
  def change
    add_column :user_pockets, :company_pocket_template_id, :integer, references: "CompanyPocketTemplate", foreign_key: true, index: true
  end
end