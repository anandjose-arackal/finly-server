class CreateUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups do |t|
      t.string :name, null: false, index: true
      t.references :company, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
