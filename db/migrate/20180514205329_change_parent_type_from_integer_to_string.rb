class ChangeParentTypeFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :field_configurations, :parent_type, :string
  end
end
