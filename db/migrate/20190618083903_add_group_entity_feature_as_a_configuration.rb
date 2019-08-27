class AddGroupEntityFeatureAsAConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :group_entity_structure, :boolean, default: false
  end
end