class CreateInvoiceAttachments < ActiveRecord::Migration
  def change
    create_table :invoice_attachments do |t|
      t.attachment :attached_file
      t.references :invoice, index: true, foreign_key: true
      t.text :description

      t.timestamps null: false
    end
  end
end
