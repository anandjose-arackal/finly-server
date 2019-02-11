class AddPurposeToUserRoleMapping < ActiveRecord::Migration[4.2]
  def change
    add_column :user_role_mappings, :purpose_id, :integer, references: "Purpose", foreign_key: true, index: true
    UserRoleMapping.update_all(purpose_id: Purpose.id_for(:expense_management))
  end
end
