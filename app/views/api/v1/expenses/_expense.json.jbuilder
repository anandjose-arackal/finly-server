json.extract! expense, :id, :date, :note, :report_id
json.user do
  json.id expense.user.id
  json.name expense.user.name
end
json.status do
  json.id expense.expense_status_id
  json.name expense.expense_status.name
end
json.amount do
  json.partial! 'api/v1/shared/amount', amount: expense.amount
end
json.type expense.expense_type_id
if expense.manual_expense?
  json.manual_expense do
    json.merchant_name expense.manual_expense.merchant_name
  end
end
json.category do
  json.id expense.category.id
  json.name expense.category.name
end
json.receipts expense.receipts.each do |receipt|
  json.large receipt.image(:large)
  json.normal receipt.image(:normal)
  json.thumb receipt.image(:thumb)
end