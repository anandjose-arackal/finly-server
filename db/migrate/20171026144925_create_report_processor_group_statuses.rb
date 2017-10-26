class CreateReportProcessorGroupStatuses < ActiveRecord::Migration
  def change
    create_table :report_processor_group_statuses do |t|

      t.timestamps null: false
    end
  end
end
