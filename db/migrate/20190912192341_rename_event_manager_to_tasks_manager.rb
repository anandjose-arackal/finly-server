class RenameEventManagerToTasksManager < ActiveRecord::Migration[5.2]
  def change
    rename_table :event_workflows, :task_workflows
  end
end
