class CreateUserPockets < ActiveRecord::Migration
  def change
    create_table :user_pockets do |t|
      t.string :name
      t.integer :balance_id, references: "Amount", foriegn_key: true, index: true
      t.integer :user_pocket_type_id, references: "UserPocketType", foriegn_key: true, index: true

      t.timestamps null: false
    end
  end
end