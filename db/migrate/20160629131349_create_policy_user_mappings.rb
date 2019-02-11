class CreatePolicyUserMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :policy_user_mappings do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :policy, index: true, foreign_key: true, null: false
      t.boolean :admin, default: false, null: false

      t.timestamps null: false
    end
  end
end
