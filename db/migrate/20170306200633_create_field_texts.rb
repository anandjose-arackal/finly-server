class CreateFieldTexts < ActiveRecord::Migration[4.2]
  def change
    create_table :field_texts do |t|
      t.text :value, null: false

      t.timestamps null: false
    end
  end
end
