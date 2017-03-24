class AddSoftDeletableToFieldConfigurations < ActiveRecord::Migration
  def change
    add_column :field_configurations, :is_deleted, :boolean, default: false, null: false
  end
end
