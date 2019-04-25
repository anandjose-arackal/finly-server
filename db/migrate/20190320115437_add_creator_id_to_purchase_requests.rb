class AddCreatorIdToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :creator_id, :integer
  end
end
