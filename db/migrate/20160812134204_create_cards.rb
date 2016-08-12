class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :ending_number
      t.string :proxy
      t.references :card_type, index: true, foreign_key: true
      t.text :description

      t.timestamps null: false
    end
  end
end
