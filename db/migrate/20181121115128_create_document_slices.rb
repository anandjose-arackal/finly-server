class CreateDocumentSlices < ActiveRecord::Migration
  def change
    create_table :document_slices do |t|
      t.integer :page_number
      t.attachment :image
      t.references :receipt, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
