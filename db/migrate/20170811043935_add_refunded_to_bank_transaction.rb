class AddRefundedToBankTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_transactions, :refunded, :boolean
  end
end
