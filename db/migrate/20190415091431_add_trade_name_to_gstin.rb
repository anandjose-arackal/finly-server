class AddTradeNameToGstin < ActiveRecord::Migration[5.2]
  def change
    add_column :gstins, :trade_name, :string
  end
end
