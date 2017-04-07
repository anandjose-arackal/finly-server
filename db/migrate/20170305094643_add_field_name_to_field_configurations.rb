class AddFieldNameToFieldConfigurations < ActiveRecord::Migration
  def change
    add_column :field_configurations, :field_name, :string, null: false
  end
end
