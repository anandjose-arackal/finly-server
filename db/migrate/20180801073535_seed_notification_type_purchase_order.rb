class SeedNotificationTypePurchaseOrder < ActiveRecord::Migration[4.2]
  def change
    NotificationType.seed_data
    NotifierType.seed_data
  end
end
