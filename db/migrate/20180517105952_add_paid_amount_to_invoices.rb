class AddPaidAmountToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :paid_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
