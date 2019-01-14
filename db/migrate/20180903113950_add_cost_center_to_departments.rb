class AddCostCenterToDepartments < ActiveRecord::Migration[4.2]
  def change
    add_reference :departments, :cost_center, index: true, foreign_key: true
  end
end
