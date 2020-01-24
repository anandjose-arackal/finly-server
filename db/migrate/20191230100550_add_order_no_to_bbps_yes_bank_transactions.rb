class AddOrderNoToBbpsYesBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_yes_bank_transactions, :order_number, :string, index: true
  end
end
