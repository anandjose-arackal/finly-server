class AddSubCategoryToBudgetTrails < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_trails, :sub_department_id, :integer, references: "Department", foreign_key: true, index: true
  end
end
