class AddUserToBankPaymentRequestComments < ActiveRecord::Migration[4.2]
  def change
    add_reference :bank_payment_request_comments, :user, index: true, foreign_key: true
  end
end
