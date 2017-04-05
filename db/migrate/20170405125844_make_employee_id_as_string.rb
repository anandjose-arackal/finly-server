class MakeEmployeeIdAsString < ActiveRecord::Migration
  def change
    change_column :user_profiles, :employee_id, :string
    change_column :user_profiles, :payroll_id, :string
  end
end
