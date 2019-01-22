class AddDepartmentToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :department_id, :integer, class_name: "Department", foreign_key: true, index: true
  end
end
