class AddOtherCurrenciesToAmountsTable < ActiveRecord::Migration[4.2]
  def change
    add_column :amounts, :HRK, :decimal, precision: 20, scale: 5
    add_column :amounts, :RUB, :decimal, precision: 20, scale: 5
    add_column :amounts, :BGN, :decimal, precision: 20, scale: 5
    add_column :amounts, :BRL, :decimal, precision: 20, scale: 5
    add_column :amounts, :CHF, :decimal, precision: 20, scale: 5
    add_column :amounts, :CNY, :decimal, precision: 20, scale: 5
    add_column :amounts, :CZK, :decimal, precision: 20, scale: 5
    add_column :amounts, :DKK, :decimal, precision: 20, scale: 5
    add_column :amounts, :HKD, :decimal, precision: 20, scale: 5
    add_column :amounts, :HUF, :decimal, precision: 20, scale: 5
    add_column :amounts, :IDR, :decimal, precision: 20, scale: 5
    add_column :amounts, :ILS, :decimal, precision: 20, scale: 5
    add_column :amounts, :JPY, :decimal, precision: 20, scale: 5
    add_column :amounts, :KRW, :decimal, precision: 20, scale: 5
    add_column :amounts, :MXN, :decimal, precision: 20, scale: 5
    add_column :amounts, :NOK, :decimal, precision: 20, scale: 5
    add_column :amounts, :NZD, :decimal, precision: 20, scale: 5
    add_column :amounts, :PHP, :decimal, precision: 20, scale: 5
    add_column :amounts, :PLN, :decimal, precision: 20, scale: 5
    add_column :amounts, :RON, :decimal, precision: 20, scale: 5
    add_column :amounts, :SEK, :decimal, precision: 20, scale: 5
    add_column :amounts, :SGD, :decimal, precision: 20, scale: 5
    add_column :amounts, :THB, :decimal, precision: 20, scale: 5
    add_column :amounts, :TRY, :decimal, precision: 20, scale: 5
    add_column :amounts, :ZAR, :decimal, precision: 20, scale: 5
    add_column :amounts, :AUD, :decimal, precision: 20, scale: 5
  end
end
