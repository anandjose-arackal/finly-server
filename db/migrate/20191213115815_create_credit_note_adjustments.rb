class CreateCreditNoteAdjustments < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_note_adjustments do |t|
      t.integer :invoice_id, references: 'Invoice', foreign_key: true, index: true
      t.integer :credit_note_id, references: 'CreditNote', foreign_key: true, index: true
      t.integer :amount_id, references: 'Amount', foreign_key: true, index: true
      t.timestamps
    end

    add_column :invoices, :cn_adjusted_amount_id, :integer, references: 'Amount', foreign_key: true, index: true
  end
end
