class AddRejectionNoteToAllDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :rejection_note, :text
    add_column :invoices, :rejection_note, :text
    add_column :bank_payment_requests, :rejection_note, :text
  end
end
