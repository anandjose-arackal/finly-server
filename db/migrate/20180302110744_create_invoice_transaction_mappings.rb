class CreateInvoiceTransactionMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :invoice_transaction_mappings do |t|
      t.integer :invoice_id, references: "OutwardInvoice", foreign_key: true, index: true
      t.integer :transaction_id, references: "VirtualAccountTransaction", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
