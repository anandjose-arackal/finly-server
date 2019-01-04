class MoveFinyTransactionToTransactionDetail < ActiveRecord::Migration
  def change
    add_column :transaction_details, :sequence_number, :integer
    
    FinlyTransaction.all.each do |transaction|
      transaction.save_transaction_detail
    end
  end
end
