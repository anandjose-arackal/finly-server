class AddCompanyIdToBudgetCriteria < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_group_criteria, :company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end
