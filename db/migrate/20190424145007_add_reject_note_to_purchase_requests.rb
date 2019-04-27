class AddRejectNoteToPurchaseRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_requests, :reject_note, :text
  end
end
