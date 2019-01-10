class ChangeParentTypeFromIntegerToString < ActiveRecord::Migration[4.2]
  def change
    change_column :field_configurations, :parent_type, :string
  end
end
