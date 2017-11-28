class AddVirtualAccountToAllTrailsInCollect < ActiveRecord::Migration
  def change
    add_column :virtual_account_collect_trails, :transaction_id, :integer, references: "VirtualAccountTransaction", foreign_key: true, index: true
  end
end
