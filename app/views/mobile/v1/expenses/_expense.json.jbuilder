json.extract! expense, :id, :date, :note, :report_id, :expense_type_id,
              :distance_value, :time_value, :per_diem_name, :per_diem_rate_value, :per_diem_quantity_value,
              :distance_rate_value, :time_rate_value, :transcribed, :merchant_name
json.user do
  json.id expense.user.id
  json.name expense.user.name
end
json.status do
  json.id expense.expense_status_id
  json.name expense.expense_status.name
end
json.amount do
  json.partial! 'mobile/v1/shared/amount', amount: expense.amount
end
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