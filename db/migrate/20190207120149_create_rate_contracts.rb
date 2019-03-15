class CreateRateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :rate_contracts do |t|
      t.string :name
      t.integer :vendor_id
      t.string :renewal_alert
      t.boolean :renewable

      t.timestamps
    end
  end
end
