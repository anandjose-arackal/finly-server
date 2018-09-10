class AddCostCenterToDepartments < ActiveRecord::Migration
  def change
    add_reference :departments, :cost_center, index: true, foreign_key: true
  end
end
