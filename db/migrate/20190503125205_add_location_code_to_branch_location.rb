class AddLocationCodeToBranchLocation < ActiveRecord::Migration[5.2]
  def change
    Purpose.seed_data
    add_column :departments, :department_code, :string, index: true
    add_column :cost_centers, :cost_center_code, :string, index: true
    BranchLocation.all.each { |loc| loc.save }
    Department.all.each { |dept| dept.save }
    CostCenter.all.each { |cost_center| cost_center.save }
  end
end
