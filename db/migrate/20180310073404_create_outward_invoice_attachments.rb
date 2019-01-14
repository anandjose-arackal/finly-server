class CreateOutwardInvoiceAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :outward_invoice_attachments do |t|
      t.attachment :attachment
      t.references :outward_invoice, index: true, foreign_key: true
      t.text :description

      t.timestamps null: false
    end
  end
end
