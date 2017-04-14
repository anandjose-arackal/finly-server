class CreateAdminUserRoleMappings < ActiveRecord::Migration
  def change
    create_table :admin_user_role_mappings do |t|
      t.references :admin_user, index: true, foreign_key: true
      t.references :admin_user_role, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
