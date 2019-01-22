class CreateTimeObjects < ActiveRecord::Migration[4.2]
  def change
    create_table :time_objects do |t|
      t.decimal :value
      t.references :physical_unit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
