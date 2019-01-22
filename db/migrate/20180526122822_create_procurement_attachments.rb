class CreateProcurementAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :procurement_attachments do |t|
      t.attachment :file
      t.string :name
      t.references :company
      t.text :description
      t.references :procurement_document, polymorphic: true

      t.timestamps null: false
    end
  end
end
