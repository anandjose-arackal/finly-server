class AddFieldNameToFieldConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :field_configurations, :field_name, :string, null: false
  end
end
