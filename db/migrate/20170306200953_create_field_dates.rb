class CreateFieldDates < ActiveRecord::Migration[4.2]
  def change
    create_table :field_dates do |t|
      t.date :value, null: false

      t.timestamps null: false
    end
  end
end
