class AddGlobalToFieldConfigurations < ActiveRecord::Migration
  def change
    add_column :field_configurations, :global, :boolean, default: true
  end
end
