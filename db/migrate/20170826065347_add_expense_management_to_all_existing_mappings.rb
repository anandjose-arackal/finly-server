class AddExpenseManagementToAllExistingMappings < ActiveRecord::Migration
  def change
    MappingPurpose.seed_data
    UserRoleMapping.update_all(purpose_id: MappingPurpose.id_for(:expense_management))
    UserManagerMapping.update_all(purpose_id: MappingPurpose.id_for(:expense_management))
  end
end
