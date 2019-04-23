class AddDetailsToGstLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :gstin_locations, :gstin_id, :integer, references: "Gstin", foreign_key: true, index: true
    add_column :gstin_locations, :gstin, :string
    add_column :gstin_locations, :location_id, :integer, references: "BranchLocation", foreign_key: true, index: true
    add_column :gstin_locations, :state_id, :integer, references: "State", foreign_key: true, index: true
    add_column :gstin_locations, :poc_name, :string
    add_column :gstin_locations, :poc_mobile_number, :string
    add_column :gstin_locations, :poc_email, :string
    add_column :gstin_locations, :poc_fax, :string
    add_column :gstin_locations, :poc_designation, :string



    add_column :vendor_tds_rates, :tds_rates_list_id, :integer, references: "TdsRatesList", foreign_key: true, index: true
  end
end
