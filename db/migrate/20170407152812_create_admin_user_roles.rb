class CreateAdminUserRoles < ActiveRecord::Migration
  def change
    create_table :admin_user_roles do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
