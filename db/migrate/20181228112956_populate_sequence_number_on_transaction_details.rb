class PopulateSequenceNumberOnTransactionDetails < ActiveRecord::Migration
  def change
    TransactionDetail. all.each do |td|
      td.update_attributes(sequence_number: td.finly_transaction.sequence_number)
    end

  end
end
