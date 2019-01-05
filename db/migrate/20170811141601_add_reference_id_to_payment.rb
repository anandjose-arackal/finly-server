class AddReferenceIdToPayment < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :reference_id, :string, index: true, unique: true
    add_column :finly_transactions, :date, :datetime, index: true
    Payment.all.each do |payment|
      payment.update(reference_id: Generator.reference_id_for(payment.initiating_account, payment.receiving_account,payment.date))
    end
    change_column_null :payments, :reference_id, false
  end
end
