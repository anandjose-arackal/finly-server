class CreateFieldConfigurationPolicyMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :policy_field_mappings do |t|
      t.references :field_configuration, index: true, foreign_key: true, null: false
      t.references :policy, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
    FieldConfiguration.where(configurable_type: 'Policy').all.each do |field_configuration|
      field_configuration.policy_field_mappings.create policy: field_configuration.configurable
    end
  end
end
