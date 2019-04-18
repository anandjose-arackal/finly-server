class AddActiveToCompanyPocketTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :company_pocket_templates, :active, :boolean, default: true
  end
end
