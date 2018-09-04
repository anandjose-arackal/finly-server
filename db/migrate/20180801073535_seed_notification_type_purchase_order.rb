class SeedNotificationTypePurchaseOrder < ActiveRecord::Migration
  def change
    NotificationType.seed_data
    NotifierType.seed_data
  end
end
