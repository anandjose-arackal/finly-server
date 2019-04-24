class CreatePurchaseRequestItemStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :purchase_request_item_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
