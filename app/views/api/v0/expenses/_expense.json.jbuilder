json.extract! expense, :id, :merchant_name, :date, :note, :user_id, :category_id, :report_id, :expense_status_id, :expense_status_name
json.amount expense.amount.value
json.user_name expense.user.name
json.category_name expense.category.name
json.type expense.expense_type_id
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