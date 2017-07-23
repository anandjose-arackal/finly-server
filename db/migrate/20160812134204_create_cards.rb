class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :user, index: true, foreign_key: true
      t.string :ending_number, null: false
      t.string :proxy, null: false
      t.references :card_type, index: true, foreign_key: true
      t.text :description
      t.boolean :is_deleted, default: false

      t.timestamps null: false
    end
  end
end
