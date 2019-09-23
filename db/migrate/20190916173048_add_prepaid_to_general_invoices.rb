class AddPrepaidToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :prepaid, :boolean
  end
end
