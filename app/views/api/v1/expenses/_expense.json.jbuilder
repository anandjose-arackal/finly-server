json.extract! expense, :id, :date, :note, :report_id, :expense_type_id,
              :distance_value, :maps_distance_value, :time_value, :per_diem_name, :per_diem_rate_value, :per_diem_quantity_value,
              :distance_rate_value, :time_rate_value, :transcribed, :merchant_name, :reimbursable, :from_cash_on_hand
json.user do
  json.id expense.user.id
  json.name expense.user.name
end
json.status do
  json.id expense.expense_status_id
  json.name expense.expense_status&.name
end

json.spent_from_name expense.spent_from&.name

json.amount do
  json.partial! 'api/v1/shared/amount', amount: expense.base_amount
end

json.original_amount do
  json.partial! 'api/v1/shared/amount', amount: expense.original_amount
end

json.converted expense.converted?
json.conversion_rate expense.conversion_rate

json.type expense.expense_type_id
# if expense.manual_expense?
#   json.merchant_name expense.manual_expense.merchant_name
# elsif expense.card_expense?
#   json.merchant_name expense.card_expense.editable_merchant
# end
json.category do
  json.id expense.category.id
  json.name expense.category.name
end
json.receipts expense.receipts.each do |receipt|
  json.large receipt.image(:large)
  json.normal receipt.image(:normal)
  json.thumb receipt.image(:thumb)
end
if expense.distance_expense?
  exp_locations = expense&.distance_expense&.locations.reject { |loc| loc.latitude.blank? or loc.longitude.blank? or loc.name.blank? or loc.address.blank? }
  json.locations exp_locations, :name, :address, :latitude, :longitude, :order, :maps_id
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
json.cancelled expense.cancelled?

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
end