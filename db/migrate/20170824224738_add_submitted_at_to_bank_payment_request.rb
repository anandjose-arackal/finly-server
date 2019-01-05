class AddSubmittedAtToBankPaymentRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_requests, :submitted_at, :datetime
  end
end
