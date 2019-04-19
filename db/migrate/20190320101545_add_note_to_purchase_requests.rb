class AddNoteToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :note, :text
  end
end
