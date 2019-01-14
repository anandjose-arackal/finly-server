class AddViewRoleIdToEmailAuthorization < ActiveRecord::Migration[4.2]
  def change
    add_reference :email_authorizations, :view_role, references: :user_roles
    add_index :email_authorizations, :token
  end
end
