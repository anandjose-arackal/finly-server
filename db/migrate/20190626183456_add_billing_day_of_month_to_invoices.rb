class AddBillingDayOfMonthToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :billing_day_of_month, :integer
  end
end
