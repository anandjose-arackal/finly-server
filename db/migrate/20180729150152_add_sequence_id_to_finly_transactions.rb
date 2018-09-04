class AddSequenceIdToFinlyTransactions < ActiveRecord::Migration
  def change
    add_column :finly_transactions, :sequence_number, :integer, index: true
  end
end
