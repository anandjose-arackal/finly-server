json.extract! @result.expense, :id, :note, :merchant_name, :user_id, :user_name, :amount_value, :category_name, :category_id, :expense_type_id,
                                    :transcribed, :reimbursable

json.distance do
  json.value @result.expense.distance_value
  json.rate_value @result.expense.distance_rate_value
end

json.time do
  json.value @result.expense.time_value
  json.rate_value @result.expense.time_rate_value
end

json.per_diem do
  json.value @result.expense.per_diem_name
  json.rate_value @result.expense.per_diem_rate_value
  json.quantity_value @result.expense.per_diem_quantity_value
end

json.date @result.expense.date.strftime("%d %b %Y")
json.formatted_date @result.expense.date.strftime("%Y-%m-%d")

json.currency do
  json.id @result.expense.currency_id rescue nil
  json.symbol @result.expense.currency_symbol rescue nil
  json.country_code @result.expense.currency_country_code
end

# currencies and amounts in case the expense is being viewed from within a report
if @result.expense.report_id.present?
  json.original_currency do
    json.id @result.expense.currency_id rescue nil
    json.symbol @result.expense.amount.currency.symbol rescue nil
    json.country_code @result.expense.amount.currency.country_code rescue nil
  end

  json.base_currency do
    json.id @result.expense.report.base_currency_id
    json.country_code @result.expense.report.base_currency_code
    json.currency_symbol @result.expense.report.base_currency_symbol
  end

  json.original_amount do
    json.value @result.expense.original_amount_value
  end

  json.currency_conversion_rate @result.conversion_rate
end


if @result.expense.card_expense?
  json.original_merchant_name @result.expense.card_expense.card_transaction.merchant_name
end

# flag to show whether a particular expense has been converted or not
json.converted @result.converted

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

# sending all the currencies and the respective symbols and codes
json.currencies do
  json.array!(Currency.all) do |currency|
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.id currency.id
  end
end

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

if @result.expense.distance_expense?
  json.locations @result.expense.distance_expense.locations, :name, :address, :latitude, :longitude, :order, :maps_id
end
