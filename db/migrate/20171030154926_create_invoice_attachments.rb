class CreateInvoiceAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :invoice_attachments do |t|
      t.attachment :attached_file
      t.references :invoice, index: true, foreign_key: true
      t.text :description

      t.timestamps null: false
    end
  end
end
