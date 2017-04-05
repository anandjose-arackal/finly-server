class AddExpenseTypesToCompanyConfiguration < ActiveRecord::Migration
  def change
    add_column :company_configurations, :other_expense_types, :boolean, default: false
  end
end
