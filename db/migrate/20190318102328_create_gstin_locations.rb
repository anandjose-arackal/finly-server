class CreateGstinLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :gstin_locations do |t|
      t.integer :vendor_id, references: "YesBankVendor", foreign_key: true, index: true
      t.references :gstin, foreign_key: true
      t.string :gstin
      t.integer :location_id, references: "BranchLocation", foreign_key: true, index: true
      t.references :state, foreign_key: true
      t.string :poc_name
      t.string :poc_mobile_number
      t.string :poc_email
      t.string :poc_fax
      t.string :poc_designation

      t.timestamps
    end
  end
end
