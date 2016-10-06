class CreateProductCombinations < ActiveRecord::Migration
  def change
    create_table :product_combinations do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
