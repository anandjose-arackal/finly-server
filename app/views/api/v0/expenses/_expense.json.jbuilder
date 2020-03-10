json.extract! expense, :id, :merchant_name, :date, :note, :user_id, :category_id, :report_id, :expense_status_id, :expense_status_name, :from_cash_on_hand,:usage_date_type
json.amount expense.amount.value
json.user_name expense.user.name
json.category_name expense.category.name
json.type expense.expense_type_id
json.spent_from_name expense.spent_from&.name
json.usage_date_start DateUtils.date_formatted expense.usage_date_start
json.usage_date_end DateUtils.date_formatted expense.usage_date_end
json.receipt_url do
  large = nil
  normal = nil
  thumb = nil
  if expense.receipts.size > 0
    large = expense.receipts.first.image(:large)
    normal = expense.receipts.first.image(:normal)
    thumb = expense.receipts.first.image(:thumb)
  end
  json.large large
  json.normal normal
  json.thumb thumb
end
json.custom_fields do
  case expense.expense_type_id
    when ExpenseType.id_for(:manual)
      json.array! expense.manual_expense.custom_fields
    when ExpenseType.id_for(:card)
      json.array! expense.card_expense.custom_fields
    when ExpenseType.id_for(:distance)
      json.array! expense.distance_expense.custom_fields
    when ExpenseType.id_for(:time)
      json.array! expense.time_expense.custom_fields
    when ExpenseType.id_for(:per_diem)
      json.array! expense.per_diem_expense.custom_fields
  end
end

# Tax details for this expense
json.tax_details do
  json.merchant_gstin expense.gstin_location&.gstin
  json.merchant_state_id expense.gstin_location&.state_id
  json.merchant_registered_name expense.gstin_location&.gstin_master&.legal_name_of_business
  json.tax_amount expense.gst_amount&.value
  json.gst_type_id expense.gst_type_id
  json.merchant_bill_no expense.merchant_bill_no
  json.hsn_sac expense.hsn_sac
  json.state_of_expense_id expense.state_of_expense_id
  json.tax_rate_id expense.tax_rate_id
  json.gstin_location_id expense.gstin_location_id
end