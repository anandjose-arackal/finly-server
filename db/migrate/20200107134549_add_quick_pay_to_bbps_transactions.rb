class AddQuickPayToBbpsTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_yes_bank_transactions, :quick_pay, :boolean, default: true
  end
end
