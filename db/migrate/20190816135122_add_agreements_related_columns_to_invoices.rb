class AddAgreementsRelatedColumnsToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :start_date, :date
    add_column :invoices, :end_date, :date
    add_column :invoices, :lock_in_period, :integer
    add_column :invoices, :rent_free_period, :integer
  end
end
