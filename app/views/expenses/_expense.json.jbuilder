json.extract! expense, :id, :note, :merchant_name, :user_name, :amount_value, :currency_id, :category_name, :expense_type_id,
              :distance_value, :time_value, :per_diem_name, :per_diem_quantity_value, :per_diem_rate_value, :transcribed, :currency_symbol,
              :currency_country_code, :partially_transcribed, :report_status
if expense.note
  if expense.note[21]
    json.note expense.note[0, 20] + '...'
  else
    json.note expense.note
  end
end
json.date DateUtils.date_formatted expense.date
json.potential_duplicate expense.has_duplicate_expenses?