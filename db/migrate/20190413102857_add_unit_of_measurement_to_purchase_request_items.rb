class AddUnitOfMeasurementToPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_request_items, :unit_of_measurement, :string
  end
end
