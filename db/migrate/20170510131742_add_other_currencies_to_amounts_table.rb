class AddOtherCurrenciesToAmountsTable < ActiveRecord::Migration
  def change
    add_column :amounts, :HRK, :decimal, precision: 10, scale: 5
    add_column :amounts, :RUB, :decimal, precision: 10, scale: 5
    add_column :amounts, :BGN, :decimal, precision: 10, scale: 5
    add_column :amounts, :BRL, :decimal, precision: 10, scale: 5
    add_column :amounts, :CHF, :decimal, precision: 10, scale: 5
    add_column :amounts, :CNY, :decimal, precision: 10, scale: 5
    add_column :amounts, :CZK, :decimal, precision: 10, scale: 5
    add_column :amounts, :DKK, :decimal, precision: 10, scale: 5
    add_column :amounts, :HKD, :decimal, precision: 10, scale: 5
    add_column :amounts, :HUF, :decimal, precision: 10, scale: 5
    add_column :amounts, :IDR, :decimal, precision: 10, scale: 5
    add_column :amounts, :ILS, :decimal, precision: 10, scale: 5
    add_column :amounts, :JPY, :decimal, precision: 10, scale: 5
    add_column :amounts, :KRW, :decimal, precision: 10, scale: 5
    add_column :amounts, :MXN, :decimal, precision: 10, scale: 5
    add_column :amounts, :NOK, :decimal, precision: 10, scale: 5
    add_column :amounts, :NZD, :decimal, precision: 10, scale: 5
    add_column :amounts, :PHP, :decimal, precision: 10, scale: 5
    add_column :amounts, :PLN, :decimal, precision: 10, scale: 5
    add_column :amounts, :RON, :decimal, precision: 10, scale: 5
    add_column :amounts, :SEK, :decimal, precision: 10, scale: 5
    add_column :amounts, :SGD, :decimal, precision: 10, scale: 5
    add_column :amounts, :THB, :decimal, precision: 10, scale: 5
    add_column :amounts, :TRY, :decimal, precision: 10, scale: 5
    add_column :amounts, :ZAR, :decimal, precision: 10, scale: 5
    add_column :amounts, :AUD, :decimal, precision: 10, scale: 5
  end
end
