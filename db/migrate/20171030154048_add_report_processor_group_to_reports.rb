class AddReportProcessorGroupToReports < ActiveRecord::Migration
  def change
    add_reference :reports, :report_processor_group_mapping, index: true, foreign_key: true
  end
end
