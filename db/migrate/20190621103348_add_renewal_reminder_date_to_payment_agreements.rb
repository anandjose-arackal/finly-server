class AddRenewalReminderDateToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreements, :renewal_reminder_date, :datetime
  end
end
