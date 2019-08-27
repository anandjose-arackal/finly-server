class CreateUserAuthFailures < ActiveRecord::Migration[5.2]
  def change
    create_table :user_auth_failures do |t|
      t.integer :user_id, index:true, foreign_key: true, null: false, references: 'user'
      t.boolean :locked, index: true

      t.timestamps
    end
  end
end
