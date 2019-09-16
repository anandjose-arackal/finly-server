class AddAncestryToCostCenters < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_centers, :ancestry, :string
    add_index :cost_centers, :ancestry
  end
end
