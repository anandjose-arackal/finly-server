class CreateUserPocketTypes < ActiveRecord::Migration
  def change
    create_table :user_pocket_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
