json.extract! @result.expense, :id, :note, :merchant_name, :user_id, :user_name, :amount_value, :category_name, :category_id, :expense_type_id,
                               :distance_value, :time_value, :per_diem_name, :per_diem_rate_value, :per_diem_quantity_value,
                               :distance_rate_value, :time_rate_value, :transcribed, :reimbursable

json.date @result.expense.date.strftime("%d %b %Y")
json.formatted_date @result.expense.date.strftime("%Y-%m-%d")

json.receipts @result.expense.receipts do |receipt|
  json.id receipt.id
  json.image do
    json.file_type receipt.file_format
    json.original receipt.image.url
    json.thumb receipt.image.url(:thumb)
  end
end

json.per_diems @result.per_diems do |per_diem|
  json.id per_diem.id
  json.name "#{per_diem.configurable.name} - #{per_diem.name}"
  json.rate_value per_diem.rate_value
end

json.violations @result.violation

json.editable @result.editable

json.deletable ((params[:view].nil? || params[:view] == 'personal') && @result.expense.deletable_expense? && @result.expense.report_id.nil?)

json.custom_fields do
  expense = @result.expense
  case expense.expense_type_id
    when ExpenseType.id_for(:manual)
      json.array! @result.expense.manual_expense.custom_fields
    when ExpenseType.id_for(:card)
      json.array! @result.expense.card_expense.custom_fields
    when ExpenseType.id_for(:distance)
      json.array! @result.expense.distance_expense.custom_fields
    when ExpenseType.id_for(:time)
      json.array! @result.expense.time_expense.custom_fields
    when ExpenseType.id_for(:per_diem)
      json.array! @result.expense.per_diem_expense.custom_fields
  end
end

json.system_messages do
  json.array!(@result.expense.system_messages.pluck(:content))
end
