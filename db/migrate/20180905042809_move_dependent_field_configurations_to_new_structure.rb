class MoveDependentFieldConfigurationsToNewStructure < ActiveRecord::Migration[4.2]
  def change
    dependent_field_configurations = FieldConfiguration.where.not(parent_id: nil)
    dependent_field_configurations.each do |field_configuration|
      parent_drop_down = field_configuration.parent
      map = field_configuration.parent_dependent_field_configuration_mappings.build(parent: parent_drop_down)
      map.save
    end
  end
end
