class CreateTimeObjects < ActiveRecord::Migration
  def change
    create_table :time_objects do |t|
      t.decimal :value
      t.references :physical_unit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
