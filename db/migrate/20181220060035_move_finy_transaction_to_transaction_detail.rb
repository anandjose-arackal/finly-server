class MoveFinyTransactionToTransactionDetail < ActiveRecord::Migration[4.2]
  def change
    add_column :transaction_details, :sequence_number, :integer

    FinlyTransaction.all.each do |transaction|
      transaction.save_transaction_detail
    end
  end
end
