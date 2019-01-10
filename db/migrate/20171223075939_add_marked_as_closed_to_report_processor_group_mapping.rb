class AddMarkedAsClosedToReportProcessorGroupMapping < ActiveRecord::Migration[4.2]
  def change
    add_column :report_processor_groups, :marked_as_closed, :boolean
    add_column :report_processor_group_mappings, :marked_as_closed, :boolean
  end
end
