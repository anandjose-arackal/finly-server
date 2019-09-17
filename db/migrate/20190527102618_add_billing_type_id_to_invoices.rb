class AddBillingTypeIdToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :billing_type_id, :integer
  end
end
