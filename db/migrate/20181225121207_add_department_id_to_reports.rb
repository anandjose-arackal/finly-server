class AddDepartmentIdToReports < ActiveRecord::Migration
  def change
    add_column :reports, :department_id, :integer, references: "Department", foreign_key: true, index: true
    add_column :reports, :sub_department_id, :integer, references: "Department", foreign_key: true, index: true
  end
end
