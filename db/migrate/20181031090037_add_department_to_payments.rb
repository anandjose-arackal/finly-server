class AddDepartmentToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :department_id, :integer, class_name: "Department", foreign_key: true, index: true
  end
end
