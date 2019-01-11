class CreateEWayBills < ActiveRecord::Migration[4.2]
  def change
    create_table :e_way_bills do |t|
      t.references :company, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :procurement, index: true, foreign_key: true
      t.integer :location_id, references: "BranchLocation", index: true, foreign_key: true
      t.integer :delivery_location_id, references: "BranchLocation", foreign_key: true, index: true
      t.integer :vendor_id, references: "YesBankVendor", foreign_key: true, index: true
      t.references :payment_term, index: true, foreign_key: true
      t.references :procurement_term, index: true, foreign_key: true
      t.string :doc_number
      t.date :date
      t.string :generated_by
      t.datetime :valid_from
      t.datetime :valid_to
      t.string :ref_doc_name
      t.string :ref_doc_date
      t.references :amount, index: true, foreign_key: true
      t.string :hsn_code
      t.string :reason_for_transportation
      t.string :mode
      t.string :vehicle_number

      t.timestamps null: false
    end
  end
end
