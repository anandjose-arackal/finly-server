class AddConfigurationForBudgetInclusion < ActiveRecord::Migration[4.2]
  def change
    add_column :company_configurations, :enforce_budget, :boolean, default: false
  end
end
