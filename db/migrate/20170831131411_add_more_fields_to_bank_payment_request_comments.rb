class AddMoreFieldsToBankPaymentRequestComments < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_payment_request_comments, :note, :text
    add_column :bank_payment_request_comments, :previous_value, :text
    add_column :bank_payment_request_comments, :new_value, :text
    add_column :bank_payment_request_comments, :edited_field, :text
  end
end
