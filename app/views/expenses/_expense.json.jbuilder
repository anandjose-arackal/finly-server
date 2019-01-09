json.extract! expense, :id, :note, :merchant_name, :user_name, :amount_value, :currency_id, :expense_type_id,
              :distance_value, :maps_distance_value, :time_value, :per_diem_name, :per_diem_quantity_value, :per_diem_rate_value, :transcribed, :currency_symbol,
              :currency_country_code, :partially_transcribed, :report_status, :expense_tax_type, :gst_percentage, :tds_percentage, :reimbursable,
              :reimbursable_amount_value, :usage_date_type

if expense.category.parent.present?
  json.category_name "#{expense.category.parent.name} - #{expense.category.name}"
else
  json.category_name expense.category.name
end

if expense.spent_from.present?
  json.pocket do
    json.pocket_name expense.spent_from&.name
    json.pocket_id expense.spent_from&.id
    json.pocket_balance expense.spent_from&.name
  end
end

json.usage_date_start DateUtils.date_formatted expense.usage_date_start
json.usage_date_end DateUtils.date_formatted expense.usage_date_end

if expense.note
  if expense.note[21]
    json.note expense.note[0, 20] + '...'
  else
    json.note expense.note
  end
end
json.incomplete expense.incomplete?

json.receipts expense.receipts do |receipt|
  json.id receipt.id
  json.image do
    json.file_type receipt.file_format
    json.original receipt.image.url
    json.thumb receipt.image.url(:thumb)
  end
end
json.date DateUtils.date_formatted expense.date
json.potential_duplicate expense.has_duplicate_expenses?

json.tds_slab do
  json.id expense.tds_slab&.id
  json.tds expense.tds_slab&.tds
end