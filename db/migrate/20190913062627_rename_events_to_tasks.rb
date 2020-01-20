class RenameEventsToTasks < ActiveRecord::Migration[5.2]
  def change
    rename_table :event_schedules, :task_schedules
    rename_table :event_file_manager_actions, :task_file_manager_actions
    ActiveRecord::Migration.rename_column :task_workflows, :event_schedule_id, :task_schedule_id
  end
end
