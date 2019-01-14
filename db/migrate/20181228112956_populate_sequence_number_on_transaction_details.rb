class PopulateSequenceNumberOnTransactionDetails < ActiveRecord::Migration[4.2]
  def change
    TransactionDetail.where(sequence_number: nil).each do |td|
      td.update_attributes(sequence_number: td.finly_transaction.sequence_number)
    end
  end
end
