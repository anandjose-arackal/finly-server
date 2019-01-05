class CreateProcurements < ActiveRecord::Migration[4.2]
  def change
    create_table :procurements do |t|
      t.string :name
      t.references :procurement_track, index: true, foreign_key: true
      t.references :procurement_status, index: true, foreign_key: true
      t.integer :vendor_id, references: "YesBankVendor", index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
