class AddSymbolToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :symbol, :string
  end
end
