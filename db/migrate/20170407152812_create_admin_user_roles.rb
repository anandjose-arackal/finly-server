class CreateAdminUserRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :admin_user_roles do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
