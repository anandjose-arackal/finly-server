class AddSubCategoryToBudgetTrails < ActiveRecord::Migration
  def change
    add_column :budget_trails, :sub_department_id, :integer, references: "Department", foreign_key: true, index: true
  end
end
