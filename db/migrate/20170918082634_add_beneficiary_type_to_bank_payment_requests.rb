class AddBeneficiaryTypeToBankPaymentRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_requests, :beneficiary_type_id, :integer
  end
end
