class MakeEmployeeIdAsString < ActiveRecord::Migration[4.2]
  def change
    change_column :user_profiles, :employee_id, :string
    change_column :user_profiles, :payroll_id, :string
  end
end
