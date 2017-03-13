class CreateDistances < ActiveRecord::Migration
  def change
    create_table :distances do |t|
      t.decimal :value
      t.references :physical_unit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
