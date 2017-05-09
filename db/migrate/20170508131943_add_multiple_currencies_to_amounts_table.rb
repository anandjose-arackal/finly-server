class AddMultipleCurrenciesToAmountsTable < ActiveRecord::Migration
  def change
    add_column :amounts, :USD, :string
    add_column :amounts, :GBP, :string
    add_column :amounts, :CAD, :string
    add_column :amounts, :EUR, :string
  end
end
