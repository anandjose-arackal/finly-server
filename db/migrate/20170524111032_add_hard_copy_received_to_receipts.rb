class AddHardCopyReceivedToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :hard_copy_received, :boolean, default: false
    add_column :feature_subscriptions, :hard_copy_receipt, :boolean, default: false
  end
end
