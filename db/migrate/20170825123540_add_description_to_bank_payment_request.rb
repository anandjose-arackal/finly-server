class AddDescriptionToBankPaymentRequest < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :description, :text
  end
end
