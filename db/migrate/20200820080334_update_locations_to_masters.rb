class UpdateLocationsToMasters < ActiveRecord::Migration[5.2]
  def change
    rename_column :branch_locations, :pin_code, :pin
    add_column :branch_locations, :start_date, :datetime, index: true
    add_column :branch_locations, :end_date, :datetime, index: true
    rename_column :branch_locations, :gstin, :tax_registration_number
  end
end
