class UpdateHardCopyDefaultToTrue < ActiveRecord::Migration
  def up
    change_column_default :receipts, :hard_copy_received, true
  end

  def down
    change_column_default :receipts, :hard_copy_received, false
  end
end
