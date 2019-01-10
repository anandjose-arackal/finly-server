class CreateBankPaymentRequestTrails < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_payment_request_trails do |t|
      t.references :bank_payment_request, index: true, foreign_key: true
      t.integer :request_status_id, references: "BankPaymentRequestStatus", foreign_key: true, index: true
      t.integer :action_user_id, references: "User", foreign_key: true, index: true
      t.integer :action_user_role_id, references: "UserRole", foreign_key: true, index: true
      t.integer :modified_user_id, references: "User", foreign_key: true, index: true
      t.integer :modified_user_role_id, references: "UserRole", foreign_key: true, index: true
      t.integer :action_id, references: "BankPaymentRequestTrailAction", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
