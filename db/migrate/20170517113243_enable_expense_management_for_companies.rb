class EnableExpenseManagementForCompanies < ActiveRecord::Migration
  def change
    # Enabling Expense Management Feature for all EXISTING Companies
    companies = Company.all
    companies.each do |company|
      company.feature_subscription.expense_management_enabled = true
      company.save
    end
  end
end
