class AddRejectNoteToPurchaseRequestItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_request_items, :reject_note, :string
  end
end
