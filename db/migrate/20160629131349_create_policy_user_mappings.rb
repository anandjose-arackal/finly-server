class CreatePolicyUserMappings < ActiveRecord::Migration
  def change
    create_table :policy_user_mappings do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :policy, index: true, foreign_key: true, null: false
      t.references :policy_user_role, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
