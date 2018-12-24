class MoveFinyTransactionToTransactionDetail < ActiveRecord::Migration
  def change
    FinlyTransaction.all.each do |transaction|
      transaction.save_transaction_detail
    end
  end
end
