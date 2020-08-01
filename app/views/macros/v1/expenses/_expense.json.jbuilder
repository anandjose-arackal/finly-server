json.id record.id
json.extract! record, :id, :note, :merchant_name, :expense_type_id,
              :transcribed, :reimbursable, :report_status, :split_link, :from_cash_on_hand, :synced_with_quickbooks,
              :expense_tax_type_id
json.created_at record.created_at
json.updated_at record.updated_at

json.user do
  json.partial! 'macros/v1/users/user', record: record.user
  json.bank_account record.user.default_bank_account
end

json.expense_type record.expense_type&.name
json.usage_dates do
  json.type record.usage_date_type
  json.start DateUtils.date_formatted record.usage_date_start
  json.end DateUtils.date_formatted record.usage_date_end
end

json.category record.category

json.pocket do
  json.id record.spent_from&.id
  json.name record.spent_from&.name
end

json.distance_expense do
  if record.distance_expense?
    json.type record.distance_expense&.type
    json.value record.distance_value
    json.maps_distance_value record.maps_distance_value

    json.vehicle_rate record.distance_expense.vehicle_rate
    json.distance_rate record.distance_expense.distance_rate
    json.distance_unit record.distance_expense.distance_unit

    json.locations record.distance_expense.locations, :name, :address, :latitude, :longitude, :order

    json.odometer_reading do
      json.start record.distance_expense&.odometer_reading_start
      json.end record.distance_expense&.odometer_reading_end
    end
  end
end

json.time_expense do
  json.value record.time_value
  json.rate_value record.time_rate_value
end

json.per_diem_expense do
  json.name record.per_diem_name
  json.rate_value record.per_diem_rate_value
  json.quantity_value record.per_diem_quantity_value
end

json.date record.date
json.formatted_date record.date

json.amount do
  json.partial! 'shared/amount', amount: record.amount
end
json.reimbursable_amount do
  json.partial! 'shared/amount', amount: record&.reimbursable_amount
end

json.tds_slab do
  json.id record.tds_slab&.id
  json.name record.tds_slab&.name
  json.tds record.tds_slab&.tds
end

json.converted_amount do
  json.partial! 'shared/amount', amount: record.base_amount
end

# flag to show whether a particular record has been converted or not
json.converted record.converted?
json.conversion_rate record.conversion_rate

if record.card_expense?
  json.card_expense do
    json.merchant_name record.card_expense&.card_transaction&.merchant_name
  end
end

json.receipts record.receipts do |receipt|
  json.id receipt.id
  json.image do
    json.file_type receipt.file_format
    json.original receipt.image.url
    json.thumb receipt.image.url(:thumb)
  end
end

json.reimbursable record.reimbursable
json.personal record.personal
json.cancellable record.cancellable?
json.cancelled record.cancelled?



custom_fields = {}
record.custom_fields.each do |cf|
  custom_fields[cf.field_configuration.field_name] = cf.configured_field_value
end
json.custom_fields custom_fields

if record.card_expense? && record.cancelled?
  json.cancelled_against_transactions do
    json.array!(record.card_expense&.cancelled_against_transactions) do |transaction|
      json.timestamp transaction.transaction_timestamp
      json.amount_value transaction.billing_amount_value
      json.type "Refund"
      json.card_number transaction.serial_id
    end
  end
end

# Tax details for this record
json.tax_details do
  gst_applicable = record.category&.gst_applicable || false
  json.expense_tax_type (gst_applicable ? record.expense_tax_type&.name&.humanize : '')
  json.merchant_gstin record.gstin_location&.gstin
  json.merchant_state_id record.gstin_location&.state_id
  json.merchant_registered_name record.gstin_location&.gstin_master&.legal_name_of_business
  json.tax_amount record.gst_amount&.value
  json.gst_type_id record.gst_type_id
  json.merchant_bill_no record.merchant_bill_no
  json.hsn_sac record.hsn_sac
  json.state_of_expense_id record.state_of_expense_id
  json.tax_rate_id record.tax_rate_id
  json.gstin_location_id record.gstin_location_id
  json.gst_percentage (gst_applicable ? record.gst_percentage : 0)
  json.gst_type (gst_applicable ? record.gst_type&.name&.humanize&.upcase : nil)
  json.gst_amount (gst_applicable ? record.gst_amount&.value&.round(2) : 0)
  json.igst_amount (gst_applicable ? (record.gst_type&.name == 'igst' ? record.gst_amount&.value : 0) : 0)
  json.cgst_amount ((gst_applicable ? (record.gst_type&.name == 'cgst_sgst' ? ((record.gst_amount&.value) / 2).round(2) : 0) : 0) rescue 0)
  json.sgst_amount ((gst_applicable ? (record.gst_type&.name == 'cgst_sgst' ? ((record.gst_amount&.value) / 2).round(2) : 0) : 0) rescue 0)
  json.net_total_amount (gst_applicable ? ((record.amount&.value || 0) - (record.gst_amount&.value&.round(2) || 0))&.round(2) : record.amount&.value)
  json.gst_location (gst_applicable ? record.gstin_location&.location : '')
  json.merchant_state (gst_applicable ? record.gstin_location&.state&.name : '')
  json.state_of_expense (gst_applicable ? record.state_of_expense&.name : '')
  json.tax_rate (gst_applicable ? record.tax_rate&.rate&.to_f : 0)
end

# report details
json.report do
  if record.report.present?
    json.id record.report_id
    json.approved_at record.report.approved_at
    json.created_at record.report.created_at
    json.note record.report.memo
    json.bank_reference_number record.report.bank_reference_number
    json.source_account record.report.source_account
    json.submitted_at record.report.submitted_at
    json.policy record.report.policy
  end
end


json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at