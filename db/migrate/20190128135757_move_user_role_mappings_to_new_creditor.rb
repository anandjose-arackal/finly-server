class MoveUserRoleMappingsToNewCreditor < ActiveRecord::Migration[5.2]
  def change
    mappings = UserRoleMapping.where(purpose_id: Purpose.id_for(:vendor_payments), user_role_id: UserRole.id_for(:finance_manager))
    mappings.update_all(user_role_id: UserRole.id_for(:creditor))
  end
end