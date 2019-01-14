class CreateTdsRatesLists < ActiveRecord::Migration[4.2]
  def change
    create_table :tds_rates_lists do |t|
      t.string :name
      t.decimal :tds, precision: 10, scale: 5

      t.timestamps null: false
    end
  end
end
