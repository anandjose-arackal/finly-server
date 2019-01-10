class AddActionForUserToBankPaymentRequestTrail < ActiveRecord::Migration[4.2]
  def change
    BankPaymentRequest.all.where(status_id: BankPaymentRequestStatus.id_for(:credited))
        .update_all(controlling_user_id: nil, controlling_user_role_id: nil, controlling_for_user_id: nil, controlling_for_user_role_id: nil)
    add_column :bank_payment_request_trails, :action_for_user_id, :integer, references: 'User', index: true, foreign_key: true
    add_column :bank_payment_request_trails, :action_for_user_role_id, :integer, references: 'User', index: true, foreign_key: true
  end
end
