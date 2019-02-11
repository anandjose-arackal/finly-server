class CreateProcurementCharges < ActiveRecord::Migration[4.2]
  def change
    create_table :procurement_charges do |t|
      t.integer :charge_type
      t.string :description
      t.references :amount, index: true, foreign_key: true
      t.boolean :taxable
      t.decimal :tax
      t.integer :tax_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :total_amount_id, references: "Amount", foreign_key: true, index: true
      t.references :chargable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
