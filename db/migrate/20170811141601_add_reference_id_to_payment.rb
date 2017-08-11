class AddReferenceIdToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :reference_id, :string, index: true, unique: true
    Payment.all.each do |payment|
      payment.update(reference_id: Generator.reference_id_for(nil, nil,nil,nil))
    end
    change_column_null :payments, :reference_id, false
  end
end
