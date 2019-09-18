class AddRemoveUnwatedColumnsFromInvoices < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoices, :is_payment_agreement_upcoming_invoice
    remove_column :invoices, :rent_free_period
    remove_column :invoices, :tenancy_period
    remove_column :invoices, :lock_in_period
    remove_column :invoices, :end_date
    remove_column :invoices, :start_date
    remove_column :invoices, :payment_agreement_upcoming_date
    remove_column :invoices, :billing_day_of_month
    remove_column :invoices, :billing_start_date
    remove_column :invoices, :invoice_frequency_id
    remove_column :invoices, :payment_agreement_escalation_id
    remove_column :invoices, :recurring_invoice_id
    add_column :invoices, :agreement_item_type, :string
    add_column :invoices, :agreement_item_id, :integer
  end
end
