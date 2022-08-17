class AddRequestedFinYearFieldToGstFilingRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :gst_filing_records, :requested_financial_year, :string
  end
end
