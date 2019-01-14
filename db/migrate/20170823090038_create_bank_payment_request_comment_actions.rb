class CreateBankPaymentRequestCommentActions < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_payment_request_comment_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
