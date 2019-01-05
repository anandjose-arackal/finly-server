class AddExpenseManagementToAllExistingMappings < ActiveRecord::Migration[4.2]
  def change
    Purpose.seed_data
    UserManagerMapping.update_all(purpose_id: Purpose.id_for(:expense_management))
  end
end
