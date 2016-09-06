class CreateAmounts < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :country
      t.string :country_code

      t.timestamps null: false
    end
    create_table :amounts do |t|
      t.float :value
      t.references :currency, index:true, foreign_key:true, null: false

      t.timestamps null: false
    end
  end
end
