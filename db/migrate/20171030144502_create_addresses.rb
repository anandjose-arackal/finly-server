class CreateAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :addresses do |t|
      t.text :line_1
      t.text :line_2
      t.text :line_3
      t.string :city
      t.references :state, foreign_key: true
      t.string :name

      t.timestamps null: false
    end
  end
end
