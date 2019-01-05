class AddNonDependentAsFlagForFieldConfigurations < ActiveRecord::Migration[4.2]
  def change
    add_column :field_configurations, :root_field, :boolean, default: true

    # now making sure all the previous field configurations are root custom fields
    FieldConfiguration.update_all(root_field: true)
  end
end
