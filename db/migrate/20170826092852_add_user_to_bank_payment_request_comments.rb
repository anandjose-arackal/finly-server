class AddUserToBankPaymentRequestComments < ActiveRecord::Migration
  def change
    add_reference :bank_payment_request_comments, :user, index: true, foreign_key: true
  end
end
