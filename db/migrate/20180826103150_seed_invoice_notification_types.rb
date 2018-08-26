class SeedInvoiceNotificationTypes < ActiveRecord::Migration
  def change
    NotifierType.seed_data
    NotificationType.seed_data
  end
end
