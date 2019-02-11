class AddSequenceIdToFinlyTransactions < ActiveRecord::Migration[4.2]
  def change
    add_column :finly_transactions, :sequence_number, :integer, index: true
  end
end
