class AddAdvanceAmountRequiredToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :advance_amount_required, :boolean, default: false
  end
end
