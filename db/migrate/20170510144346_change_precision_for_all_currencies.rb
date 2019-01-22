class ChangePrecisionForAllCurrencies < ActiveRecord::Migration[4.2]
  def change
    change_column :amounts, :INR, :decimal, precision: 20, scale: 5
    change_column :amounts, :USD, :decimal, precision: 20, scale: 5
    change_column :amounts, :GBP, :decimal, precision: 20, scale: 5
    change_column :amounts, :CAD, :decimal, precision: 20, scale: 5
    change_column :amounts, :EUR, :decimal, precision: 20, scale: 5
  end
end
