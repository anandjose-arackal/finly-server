class AddBillingCycleToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :billing_cycle_from, :date
    add_column :invoices, :billing_cycle_to, :date
    
    add_index :invoices, :billing_cycle_from
    add_index :invoices, :billing_cycle_to

  end
end
