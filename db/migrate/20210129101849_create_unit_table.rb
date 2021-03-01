class CreateUnitTable < ActiveRecord::Migration[6.0]
  def change
    create_table :units do |t|
      t.string :name, default: ""
      t.string :value, default: ""
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
