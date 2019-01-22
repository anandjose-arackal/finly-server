class CreateUserGroupItems < ActiveRecord::Migration[4.2]
  def change
    create_table :user_group_items do |t|
      t.string :name, null: false, index: true
      t.references :user_group, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
