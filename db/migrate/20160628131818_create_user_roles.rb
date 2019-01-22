class CreateUserRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :user_roles do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
