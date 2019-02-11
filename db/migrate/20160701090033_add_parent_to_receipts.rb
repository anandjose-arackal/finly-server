class AddParentToReceipts < ActiveRecord::Migration[4.2]
  def change
    add_reference :receipts, :parent, index: true, polymorphic: true
  end
end
