class CreateUserFieldMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_field_mappings do |t|
      t.integer :user_id, references: "User", foreign_key: true, index: true
      t.integer :field_configuration_id, references: "FieldConfiguration", foreign_key: true, index: true
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
