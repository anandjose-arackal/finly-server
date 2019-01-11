class AddGlobalToFieldConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :field_configurations, :global, :boolean, default: true
  end
end
