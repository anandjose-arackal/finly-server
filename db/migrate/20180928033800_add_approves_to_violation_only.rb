class AddApprovesToViolationOnly < ActiveRecord::Migration[4.2]
  def change
    add_column :user_manager_mappings, :approves_to_violation_only, :boolean, default: false, index: true
    add_column :user_manager_mappings, :approves_finance_to_violation_only, :boolean, default: false, index: true
  end
end
