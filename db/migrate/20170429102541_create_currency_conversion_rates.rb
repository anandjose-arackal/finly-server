class CreateCurrencyConversionRates < ActiveRecord::Migration
  def change
    create_table :currency_conversion_rates do |t|
      t.date :date
      t.decimal :INR
      t.decimal :USD
      t.decimal :GBP
      t.decimal :EUR

      t.timestamps null: false
    end
  end
end
