class CreateVendorTdsRates < ActiveRecord::Migration[5.2]
  def change
    create_table :vendor_tds_rates do |t|
      t.integer :vendor_id, references: "YesBankVendor", foreign_key: true, index: true
      t.references :tds_rates_list, foreign_key: true

      t.timestamps
    end
  end
end
