class AddRefundedToBankTransaction < ActiveRecord::Migration
  def change
    add_column :bank_transactions, :refunded, :boolean
  end
end
