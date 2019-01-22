class CreateFieldDateTimes < ActiveRecord::Migration[4.2]
  def change
    create_table :field_date_times do |t|
      t.datetime :value, null: false

      t.timestamps null: false
    end
  end
end
