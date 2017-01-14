json.extract! @result.expense, :id, :note, :merchant_name, :user_id, :user_name, :amount_value, :category_name, :category_id, :expense_type_id

json.date @result.expense.date.strftime("%d %b %Y")
json.formatted_date @result.expense.date.strftime("%Y-%m-%d")

json.receipts @result.expense.receipts do |receipt|
  json.id receipt.id
  json.image_url receipt.image.url
end

json.violations @result.violation

json.editable @result.editable

json.deletable ((params[:view].nil? or params[:view] == 'personal') and @result.expense.manual_expense?)