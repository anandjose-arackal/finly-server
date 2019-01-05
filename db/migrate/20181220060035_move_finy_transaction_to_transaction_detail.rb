class MoveFinyTransactionToTransactionDetail < ActiveRecord::Migration[4.2]
  def change
    FinlyTransaction.all.each do |transaction|
      transaction.save_transaction_detail
    end
  end
end
