class AddNoteToReportProcessMapping < ActiveRecord::Migration
  def change
    add_column :report_processor_group_mappings, :note, :text
  end
end
