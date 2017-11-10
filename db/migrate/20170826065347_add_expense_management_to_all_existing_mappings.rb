class AddExpenseManagementToAllExistingMappings < ActiveRecord::Migration
  def change
    Purpose.seed_data
    UserManagerMapping.update_all(purpose_id: Purpose.id_for(:expense_management))
  end
end
