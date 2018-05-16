class AddReferenceToFieldConfigurationInDropDown < ActiveRecord::Migration
  def change
    add_column :field_configurations, :parent_id, :integer, polymorphic: true, foreign_key: true, index: true
    add_column :field_configurations, :parent_type, :integer, polymorphic: true, foreign_key: true, index: true
  end
end
