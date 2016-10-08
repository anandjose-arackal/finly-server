class CreateUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name, null: false
      t.boolean :active, null: false, default: true

      t.timestamps null: false
    end
  end
end
