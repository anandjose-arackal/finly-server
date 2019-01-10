class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.string :name, null: false
      t.string :gl_code
      t.string :payroll_code
      t.boolean :active, null: false, default: true

      t.timestamps null: false
    end
  end
end
