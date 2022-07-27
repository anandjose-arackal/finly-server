class AddCreditNoteAdjustedAmountToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :invoice_credit_note_adjusted_amount, :decimal, precision: 20, scale: 10, default: 0
  end
end
