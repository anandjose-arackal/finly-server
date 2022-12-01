json.result do

  json.array!(@result.gst_filing_records_response) do |gst_filing_record|
    json.extract! gst_filing_record, :id, :date_of_filing, :mode_of_filing, :return_period, :return_period_date, :status, :valid_text, :return_type, :gstin, :financial_year, :arn, :company_id, :created_at, :updated_at
  end
end