class AddSoftDeletableToFieldConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :field_configurations, :is_deleted, :boolean, default: false, null: false
  end
end
