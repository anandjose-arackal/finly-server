json.array!(@expenses) do |expense|
  json.extract! expense, :id, :note, :merchant_name, :user_name, :amount_value, :category_name
  json.date expense.date.strftime("%d %b")
end