class AddDeletedAtToGstFilingApiCallLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :gst_filing_api_call_logs, :deleted_at, :datetime
  end
end
