class AddCompanyPocketTemplateToUserPockets < ActiveRecord::Migration
  def change
    add_column :user_pockets, :company_pocket_template_id, :integer, references: "CompanyPocketTemplate", foreign_key: true, index: true
  end
end