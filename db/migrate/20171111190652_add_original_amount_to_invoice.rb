class AddOriginalAmountToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :original_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
