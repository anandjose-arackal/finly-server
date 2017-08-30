class AddSubmittedAtToBankPaymentRequest < ActiveRecord::Migration
  def change
    add_column :bank_payment_requests, :submitted_at, :datetime
  end
end
