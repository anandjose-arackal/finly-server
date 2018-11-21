class AddConfigurationForBudgetInclusion < ActiveRecord::Migration
  def change
    add_column :company_configurations, :enforce_budget, :boolean, default: false
  end
end
