class AddSequenceIdToFinlyTransactions < ActiveRecord::Migration
  def change
    add_column :finly_transactions, :sequence_number, :integer, index: true
    FinlyTransaction.all.each do |ft|
      ft.update(sequence_number: (ft.id * 10))
    end
  end
end
