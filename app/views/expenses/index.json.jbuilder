json.array!(@result.paginated_expenses) do |expense|
  json.extract! expense, :id, :note, :merchant_name, :user_name, :amount_value, :category_name, :expense_type_id,
                         :distance_value, :time_value, :per_diem_name, :per_diem_quantity_value, :per_diem_rate_value, :transcribed
  if expense.note
    if expense.note[21]
      json.note expense.note[0, 20] + "..."
    else
      json.note expense.note
    end
  end
  json.date expense.date.strftime("%d %b %Y")
end