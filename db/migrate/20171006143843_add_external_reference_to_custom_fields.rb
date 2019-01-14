class AddExternalReferenceToCustomFields < ActiveRecord::Migration[4.2]
  def change
    add_column :field_configurations, :external_reference_type, :string, polymorphic: true
    add_column :field_configurations, :external_reference_id, :integer, polymorphic: true
  end
end
