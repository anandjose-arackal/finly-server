class AddIndexToBankPaymentRequestComments < ActiveRecord::Migration[6.0]
  def change
    add_index :bank_payment_request_comments, [:bank_payment_request_id, :company_id], name: 'index_bank_payment_request_comments_on_bpr_id_and_company_id'
  end
end
