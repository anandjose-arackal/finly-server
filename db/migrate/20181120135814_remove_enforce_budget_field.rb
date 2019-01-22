class RemoveEnforceBudgetField < ActiveRecord::Migration[4.2]
  def change
    remove_column :company_configurations, :enforce_budget,:boolean
  end
end
