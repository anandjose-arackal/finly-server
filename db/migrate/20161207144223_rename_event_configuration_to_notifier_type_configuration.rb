class RenameEventConfigurationToNotifierTypeConfiguration < ActiveRecord::Migration[4.2]
  def change
    rename_table :event_configurations, :notifier_type_configurations
  end
end
