class CreateRateContractLineItems < ActiveRecord::Migration[5.2]
  def change
    create_table :rate_contract_line_items do |t|
      t.integer :location_id
      t.integer :item_id
      t.datetime :start_date
      t.datetime :end_date
      t.decimal :amount
      t.integer :rate_contract_id

      t.timestamps
    end
  end
end
