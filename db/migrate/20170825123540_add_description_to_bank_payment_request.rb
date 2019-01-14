class AddDescriptionToBankPaymentRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_requests, :description, :text
  end
end
