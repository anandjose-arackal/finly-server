class AddNoticePeriodAndSquareFeetToRentalInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :rental_invoices, :notice_period, :integer
    add_column :rental_invoices, :square_feel, :decimal, precision: 10, scale: 5
  end
end
