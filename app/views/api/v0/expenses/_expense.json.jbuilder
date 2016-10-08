json.extract! expense, :id, :merchant_name, :date, :note, :user_id, :category_id, :report_id, :expense_status_id, :expense_status_name
json.amount expense.amount.value
json.user_name expense.user.name
json.category_name expense.category.name
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