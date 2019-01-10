class AddEditTermsWithinPoToUserPermissions < ActiveRecord::Migration[4.2]
  def change
    add_column :user_permissions, :edit_terms_within_po, :boolean, default: false
  end
end
