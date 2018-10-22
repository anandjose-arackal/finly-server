class AddEditTermsWithinPoToUserPermissions < ActiveRecord::Migration
  def change
    add_column :user_permissions, :edit_terms_within_po, :boolean, default: false
  end
end
