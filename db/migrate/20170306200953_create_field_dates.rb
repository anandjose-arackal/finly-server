class CreateFieldDates < ActiveRecord::Migration
  def change
    create_table :field_dates do |t|
      t.datetime :value, null: false

      t.timestamps null: false
    end
  end
end
