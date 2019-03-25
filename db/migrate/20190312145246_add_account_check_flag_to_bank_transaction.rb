class AddAccountCheckFlagToBankTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_transactions, :account_name_check, :boolean, default: false
  end
end