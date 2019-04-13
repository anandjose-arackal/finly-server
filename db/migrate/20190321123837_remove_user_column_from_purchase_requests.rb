class RemoveUserColumnFromPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :purchase_requests, :user_id, :integer
  end
end
