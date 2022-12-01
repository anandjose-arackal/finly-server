class RenameValidFieldInGstFilingRecords < ActiveRecord::Migration[6.0]
  def change
    rename_column :gst_filing_records, :valid, :valid_text
  end
end
