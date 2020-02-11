class AddColumnUserLevelCustomFieldsToFeatureSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :user_level_custom_fields, :boolean, default: false
  end
end
