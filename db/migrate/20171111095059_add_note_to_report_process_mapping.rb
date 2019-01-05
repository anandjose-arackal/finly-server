class AddNoteToReportProcessMapping < ActiveRecord::Migration[4.2]
  def change
    add_column :report_processor_group_mappings, :note, :text
  end
end
