class AddReceiptEmailStatusToReceiptEmail < ActiveRecord::Migration[5.2]
  def change
    add_reference :receipt_emails, :receipt_email_status, foreign_key: true
  end
end
