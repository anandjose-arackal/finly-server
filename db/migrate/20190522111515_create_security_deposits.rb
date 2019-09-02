class CreateSecurityDeposits < ActiveRecord::Migration[5.2]
  def change
    create_table :security_deposits do |t|
      t.integer :vendor_id
      t.integer :vendor_location_id
      t.integer :cost_center_id
      t.integer :department_id
      t.integer :location_id
      t.text :note
      t.text :description
      t.integer :payable_amount_id
      t.integer :original_amount_id

      t.timestamps
    end
  end
end
