class AddDepartmentIdToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :department_id, :integer, references: "Department", foreign_key: true, index: true
    add_column :reports, :sub_department_id, :integer, references: "Department", foreign_key: true, index: true
  end
end
