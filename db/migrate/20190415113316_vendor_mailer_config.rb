class VendorMailerConfig < ActiveRecord::Migration[5.2]
  def change
    NotifierType.seed_data
    NotificationType.seed_data
  end
end
