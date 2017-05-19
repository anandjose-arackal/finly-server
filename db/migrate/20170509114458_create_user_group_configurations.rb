class CreateUserGroupConfigurations < ActiveRecord::Migration
  def change
    create_table :user_group_configurations do |t|

      t.references :company, null: false, index: true, foreign_key: false

      t.timestamps null: false
    end
  end
end
