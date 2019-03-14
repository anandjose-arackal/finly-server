class AddCompanyIdToBankPaymentRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_payment_requests, :company_id, :integer
  end
end
