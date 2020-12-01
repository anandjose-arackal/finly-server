class AddEnforcePurchaseRequestBudgetToEnforceBudgetConfiguration < ActiveRecord::Migration[6.0]
  def change
    add_column :enforce_budget_configurations, :enforce_purchase_request_budget, :boolean, null: false, default: false
  end
end
