class AddTotalAmountIdToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreements, :total_amount_id, :integer
    add_index :payment_agreements, :total_amount_id
  end
end
