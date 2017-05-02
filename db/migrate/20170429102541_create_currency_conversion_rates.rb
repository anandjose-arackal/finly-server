class CreateCurrencyConversionRates < ActiveRecord::Migration
  def change
    create_table :currency_conversion_rates do |t|
      t.date :date, null: false, index: true
      t.decimal :INR, precision: 10, scale: 5
      t.decimal :USD, precision: 10, scale: 5
      t.decimal :GBP, precision: 10, scale: 5
      t.decimal :EUR, precision: 10, scale: 5
      t.decimal :CAD, precision: 10, scale: 5
      t.decimal :HRK, precision: 10, scale: 5
      t.decimal :RUB, precision: 10, scale: 5
      t.decimal :BGN, precision: 10, scale: 5
      t.decimal :BRL, precision: 10, scale: 5
      t.decimal :CHF, precision: 10, scale: 5
      t.decimal :CNY, precision: 10, scale: 5
      t.decimal :CZK, precision: 10, scale: 5
      t.decimal "DKK", precision: 10, scale: 5
      t.decimal "HKD", precision: 10, scale: 5
      t.decimal "HRK", precision: 10, scale: 5
      t.decimal "HUF", precision: 10, scale: 5
      t.decimal "IDR", precision: 10, scale: 5
      t.decimal "ILS", precision: 10, scale: 5
      t.decimal "JPY", precision: 10, scale: 5
      t.decimal "KRW", precision: 10, scale: 5
      t.decimal "MXN", precision: 10, scale: 5
      t.decimal "MYR", precision: 10, scale: 5
      t.decimal "NOK", precision: 10, scale: 5
      t.decimal "NZD", precision: 10, scale: 5
      t.decimal "PHP", precision: 10, scale: 5
      t.decimal "PLN", precision: 10, scale: 5
      t.decimal "RON", precision: 10, scale: 5
      t.decimal "SEK", precision: 10, scale: 5
      t.decimal "SGD", precision: 10, scale: 5
      t.decimal "THB", precision: 10, scale: 5
      t.decimal "TRY", precision: 10, scale: 5
      t.decimal "ZAR", precision: 10, scale: 5
      t.decimal "AUD", precision: 10, scale: 5

      t.timestamps null: false
    end
  end
end
