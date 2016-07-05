class CreateUserRoleMappings < ActiveRecord::Migration
  def change
    create_table :user_role_mappings do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :user_role, index: true, foreign_key: true, null: false
      t.references :policy, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
