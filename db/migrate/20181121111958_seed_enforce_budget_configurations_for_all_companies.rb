class SeedEnforceBudgetConfigurationsForAllCompanies < ActiveRecord::Migration[4.2]
  def change
    Company.all.each do |company|
      company.build_enforce_budget_configuration(enforce_purchase_order_budget: false, enforce_payment_budget: false,
                                                 enforce_expense_budget: false, enforce_invoice_budget: false).save
    end
  end
end