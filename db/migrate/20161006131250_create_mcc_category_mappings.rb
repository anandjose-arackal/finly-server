class CreateMccCategoryMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :mcc_category_mappings do |t|
      t.references :category, index: true, foreign_key: true
      t.string :mcc_code

      t.timestamps null: false
    end
  end
end
