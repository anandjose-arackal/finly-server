class CreateInwardDocuments < ActiveRecord::Migration[4.2]
  def change
    create_table :inward_documents do |t|
      t.references :company, index: true, foreign_key: true
      t.references :procurement, index: true, foreign_key: true
      t.integer :vendor_id, references: "YesBankVendor", index: true, foreign_key: true

      t.string :doc_number
      t.string :override_doc_number
      t.string :prefix

      t.date :delivery_date
      t.string :transported_name
      t.string :transporter_document_number
      t.string :vehicle_number

      t.timestamps null: false
    end
  end
end
