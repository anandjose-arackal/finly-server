class AddSymbolToCurrencies < ActiveRecord::Migration[4.2]
  def change
    add_column :currencies, :symbol, :string
  end
end
