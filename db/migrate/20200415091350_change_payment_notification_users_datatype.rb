class ChangePaymentNotificationUsersDatatype < ActiveRecord::Migration[5.2]
  def change
    change_column :beneficiary_payments, :payment_notification_users, :text
  end
end
