class RemoveEnforceBudgetField < ActiveRecord::Migration
  def change
    remove_column :company_configurations, :enforce_budget,:boolean
  end
end
