class AddDeletedAtToGstFilingRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :gst_filing_records, :deleted_at, :datetime
  end
end
