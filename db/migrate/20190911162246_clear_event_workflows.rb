class ClearEventWorkflows < ActiveRecord::Migration[5.2]
  def change
    remove_column :event_workflows, :uuid
    add_column :event_workflows, :uuid, :string, limit: 36, index: true, null: false
  end
end
