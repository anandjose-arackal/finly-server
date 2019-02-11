class AddForwardedToUserToPaymentRequestComment < ActiveRecord::Migration[4.2]
  def change
    # rename_column :bank_payment_request_comments, :user_id, :action_user_id
    add_column :bank_payment_request_comments, :forwarded_to_user_id, :integer, references: "User", foreign_key: true, index: true
  end
end
