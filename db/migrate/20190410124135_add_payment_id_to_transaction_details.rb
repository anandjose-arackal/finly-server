class AddPaymentIdToTransactionDetails < ActiveRecord::Migration[5.2]
  def change
    add_reference :transaction_details, :payment, index: true
  end
end
