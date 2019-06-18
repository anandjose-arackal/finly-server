class AddPaymentNotificationUsersToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :payment_notification_users, :json
  end
end
