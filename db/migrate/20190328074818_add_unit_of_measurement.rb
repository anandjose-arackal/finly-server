class AddUnitOfMeasurement < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :unit_of_measurement, :string, index: true
    add_column :purchase_order_items, :unit_of_measurement, :string, index: true
    add_column :invoice_line_items, :unit_of_measurement, :string, index: true
  end
end
