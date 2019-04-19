class AddColumnsToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :submitted_at, :datetime
    add_column :purchase_requests, :approved_at, :datetime
  end
end
