class CreateBranchLocations < ActiveRecord::Migration[4.2]
  def change
    create_table :branch_locations do |t|
      t.string :name
      t.string :gstin
      t.string :pan
      t.references :company, index: true, foreign_key: true
      t.string :address_1
      t.string :address_2
      t.string :city
      t.references :state, index: true, foreign_key: true
      t.string :country
      t.string :pin

      t.timestamps null: false
    end
  end
end
