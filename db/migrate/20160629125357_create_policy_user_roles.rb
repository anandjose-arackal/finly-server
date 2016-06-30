class CreatePolicyUserRoles < ActiveRecord::Migration
  def change
    create_table :policy_user_roles do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
