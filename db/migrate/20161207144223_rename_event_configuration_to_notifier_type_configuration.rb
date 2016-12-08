class RenameEventConfigurationToNotifierTypeConfiguration < ActiveRecord::Migration
  def change
    rename_table :event_configurations, :notifier_type_configurations
  end
end
