class CreateCreditNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_notes do |t|
      t.integer :company_id, references: 'Company', foreign_key: true, index: true
      t.integer :user_id, references: 'User', foreign_key: true, index: true
      t.integer :invoice_id, references: 'Invoice', foreign_key: true, index: true
      t.integer :procurement_id, references: 'Procurement', foreign_key: true, index: true
      t.integer :status_id, references: 'CreditNoteStatus', foreign_key: true, index: true
      t.integer :controlling_level_id, references: 'ReviewalLevel', foreign_key: true, index: true
      t.integer :policy_id, references: 'Policy', foreign_key: true, index: true
      t.integer :vendor_id, references: 'YesBankVendor', foreign_key: true, index: true
      t.integer :shipping_location_id, references: 'BranchLocation', foreign_key: true, index: true
      t.integer :billing_location_id, references: 'BranchLocation', foreign_key: true, index: true

      t.string :sequence_id, index: true
      t.date :credit_note_date, index: true

      t.text :narration
      t.text :billing_address
      t.text :shipping_address

      t.integer :gross_receivable_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :gst_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :discount_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :net_receivable_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :tds_rate_id, references: 'Amount', foreign_key: true, index: true
      t.integer :tds_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :freight_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :previously_adjusted_amount_id, references: 'Amount', foreign_key: true, index: true
      t.integer :net_adjustable_amount_id, references: 'Amount', foreign_key: true, index: true

      t.timestamps
    end
  end
end
