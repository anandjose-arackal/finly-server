class AddBillingStartDateToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :billing_start_date, :datetime
  end
end
