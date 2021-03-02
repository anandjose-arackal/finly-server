class ChangeColumnAncestoryOnCostCenters < ActiveRecord::Migration[6.0]
  def change
    change_column :cost_centers, :ancestry, "VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_general_ci"
  end
end
