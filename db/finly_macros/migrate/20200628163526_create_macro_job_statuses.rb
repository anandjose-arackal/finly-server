class CreateMacroJobStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :macro_job_statuses do |t|
      t.string :name, index: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
    MacroJobStatus.seed_data
  end
end
