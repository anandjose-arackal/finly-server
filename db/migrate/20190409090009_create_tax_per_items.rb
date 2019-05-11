class CreateTaxPerItems < ActiveRecord::Migration[5.2]
  def change
    create_table :tax_per_items do |t|
      t.references :document, polymorphic: true
      t.references :tax_rate, polymorphic: true
      t.integer :cgst_id, references: "Amount", foreign_key: true, index: true
      t.integer :sgst_id, references: "Amount", foreign_key: true, index: true
      t.integer :igst_id, references: "Amount", foreign_key: true, index: true

      t.timestamps
    end
  end
end
