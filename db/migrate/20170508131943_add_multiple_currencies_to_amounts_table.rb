class AddMultipleCurrenciesToAmountsTable < ActiveRecord::Migration
  def change
    add_column :amounts, :USD, :decimal, precision: 10, scale: 5
    add_column :amounts, :GBP, :decimal, precision: 10, scale: 5
    add_column :amounts, :CAD, :decimal, precision: 10, scale: 5
    add_column :amounts, :EUR, :decimal, precision: 10, scale: 5
  end
end
