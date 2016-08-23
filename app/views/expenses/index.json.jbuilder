json.array!(@expenses) do |expense|
  json.extract! expense, :id, :note, :merchant_name, :user_name, :amount_value, :category_name
  if expense.note
    if expense.note[21]
      json.note expense.note[0, 20] + "..."
    else
      json.note expense.note
    end
  end
  json.date expense.date.strftime("%d %b")
end