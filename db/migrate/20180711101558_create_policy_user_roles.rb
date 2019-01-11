class CreatePolicyUserRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :policy_user_roles do |t|
      t.references :policy, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :user_role, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
