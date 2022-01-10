class AddRetriveConversionRateColumn < ActiveRecord::Migration[6.0]
  def change
    add_column :purchase_orders, :retrieve_conversion_rate, :boolean
  end
end
