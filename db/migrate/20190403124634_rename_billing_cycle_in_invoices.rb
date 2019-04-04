class RenameBillingCycleInInvoices < ActiveRecord::Migration[5.2]
  def change
  	rename_column :invoices, :billing_cycle_from, :transaction_service_period_from
  	rename_column :invoices, :billing_cycle_to, :transaction_service_period_to
  end
end
