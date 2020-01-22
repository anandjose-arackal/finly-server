class RenameColumnInBbpsTransactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :bbps_yes_bank_transactions, :order_number
    rename_column :bbps_yes_bank_transactions, :ref_no, :order_number
  end
end
