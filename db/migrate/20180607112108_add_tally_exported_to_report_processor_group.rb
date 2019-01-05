class AddTallyExportedToReportProcessorGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :report_processor_groups, :tally_exported, :boolean, :default => false, index: true
  end
end
