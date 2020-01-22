class CreateEventSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :event_schedules do |t|
      t.integer :every
      t.integer :hour
      t.integer :minute
      t.integer :day_of_the_week
      t.integer :day_of_the_month

      t.timestamps
    end
    add_column :event_workflows, :event_schedule_id, :integer, references: "event_schedules", index: true, foreign_key: true
  end
end
