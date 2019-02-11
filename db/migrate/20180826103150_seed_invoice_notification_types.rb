class SeedInvoiceNotificationTypes < ActiveRecord::Migration[4.2]
  def change
    NotifierType.seed_data
    NotificationType.seed_data
  end
end
