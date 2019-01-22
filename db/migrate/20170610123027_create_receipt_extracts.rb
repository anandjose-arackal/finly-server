class CreateReceiptExtracts < ActiveRecord::Migration[4.2]
  def change
    create_table :receipt_extract_sources do |t|
      t.string :name

      t.timestamps null: false
    end
    create_table :receipt_extracts do |t|
      t.string :merchant
      t.string :reference_id
      t.date :date
      t.time :time
      t.references :amount, index: true, foreign_key: true
      t.references :receipt, index: true, foreign_key: true, null: false
      t.references :receipt_extract_source, index: true, foreign_key: true, null: false
      t.references :category, index: true, foreign_key: true
      t.integer :sourcable_id, index: true
      t.string :sourcable_type, index: true
      t.boolean :illegible

      t.timestamps null: false
    end
  end
end
