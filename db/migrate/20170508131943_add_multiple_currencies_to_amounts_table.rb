class AddMultipleCurrenciesToAmountsTable < ActiveRecord::Migration
  def change
    add_column :amounts, :USD, :string
    
  end
end
