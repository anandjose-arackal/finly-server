class AddHsnSacToPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_request_items, :hsn_sac, :string
    add_index :purchase_request_items, :hsn_sac
  end
end
