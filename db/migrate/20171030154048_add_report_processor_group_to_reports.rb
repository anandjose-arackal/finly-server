class AddReportProcessorGroupToReports < ActiveRecord::Migration[4.2]
  def change
    add_reference :reports, :report_processor_group_mapping, index: true, foreign_key: true
  end
end
