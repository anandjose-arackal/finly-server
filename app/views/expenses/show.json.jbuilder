json.extract! @result.expense, :id, :note, :merchant_name, :user_id, :user_name, :amount_value, :category_name, :category_id, :expense_type_id,
                               :distance_value, :time_value, :per_diem_name, :per_diem_rate_value, :per_diem_quantity_value,
                               :distance_rate_value, :time_rate_value, :transcribed, :reimbursable

json.date @result.expense.date.strftime("%d %b %Y")
json.formatted_date @result.expense.date.strftime("%Y-%m-%d")
json.currency_id @result.expense.currency_id rescue nil
json.original_currency_id @result.expense.currency_id rescue nil

if @result.expense.report_id.present?
  json.original_amount_value @result.expense.original_amount_value
  json.base_currency_id @result.expense.report.base_currency_id
end

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

json.show_options @result.expense.report.blank? && (params[:view] == 'personal' || params[:view].nil?)

json.deletable ((params[:view].nil? || params[:view] == 'personal') && @result.expense.deletable_expense? && @result.expense.report_id.nil?)

json.reimbursable @result.expense.reimbursable

json.personal @result.expense.personal

json.cancellable @result.expense.cancellable?

json.cancelled @result.expense.cancelled?

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

if @result.expense.card_expense? && @result.expense.cancelled?
  json.cancelled_against_transactions do
    json.array!(@result.expense.card_expense&.cancelled_against_transactions) do |transaction|
      json.timestamp transaction.transaction_timestamp
      json.amount_value transaction.billing_amount_value
      json.type "Refund"
      json.card_number "XXXXXXXXXXXX#{transaction.card.ending_number}"
    end
  end
end
