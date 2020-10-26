class AddCompanyIdToMoreModels < ActiveRecord::Migration[5.2]
  def change
    add_column :form_choice_dependency_mappings, :company_id, :integer, references: 'Company', foreign_key: true, index: true
  end
end
