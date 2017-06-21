class AddViewRoleIdToEmailAuthorization < ActiveRecord::Migration
  def change
    add_reference :email_authorizations, :view_role, references: :user_roles
    add_index :email_authorizations, :token
  end
end
