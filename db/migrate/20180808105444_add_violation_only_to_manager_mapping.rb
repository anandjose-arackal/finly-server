class AddViolationOnlyToManagerMapping < ActiveRecord::Migration[4.2]
  def change
    add_column :user_manager_mappings, :manager_violation_only, :boolean, index: true
    add_column :user_manager_mappings, :finance_violation_only, :boolean, index: true
  end
end