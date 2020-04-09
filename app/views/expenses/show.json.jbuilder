expense = @result.expense
json.extract! @result.expense, :id, :note, :merchant_name, :user_id, :user_name, :category_name, :category_id, :expense_type_id,
                                    :transcribed, :reimbursable, :report_status, :split_link, :from_cash_on_hand, :synced_with_quickbooks,
                                    :expense_tax_type_id, :gst_type_id, :gst_percentage, :tds_slab_id, :usage_date_type, :usage_date_start, :usage_date_end
json.usage_date_start DateUtils.date_formatted @result.expense.usage_date_start
json.usage_date_end DateUtils.date_formatted @result.expense.usage_date_end
if @result.expense.category.parent.present?
  json.parent_category_name @result.expense.category.parent.name
  json.parent_category_id @result.expense.category.parent.id
end


if @result.expense.spent_from.present?
  json.pocket do
    json.pocket_name @result.expense.spent_from&.name
    json.pocket_id @result.expense.spent_from&.id
    json.pocket_balance @result.expense.spent_from&.name
  end
end

json.cash_pockets @result.cash_pockets

if @result.expense.report.present?
  json.report_id @result.expense.report_id
end

json.distance do
  if @result.expense.distance_expense?
    json.type @result.expense.distance_expense&.type
    json.value @result.expense.distance_value
    json.maps_distance_value @result.expense.maps_distance_value

    json.vehicle_rate @result.expense.distance_expense.vehicle_rate
    json.distance_rate @result.expense.distance_expense.distance_rate
    json.distance_unit @result.expense.distance_expense.distance_unit

    json.odometer_reading_start @result.expense.distance_expense&.odometer_reading_start
    json.odometer_reading_end @result.expense.distance_expense&.odometer_reading_end
    json.odometer_reading_receipt_start @result.start_receipt
    json.odometer_reading_receipt_end @result.end_receipt
  end
end

json.time do
  json.value @result.expense.time_value
  json.rate_value @result.expense.time_rate_value
end

json.vehicle_rates @result.vehicle_rates

json.per_diem do
  json.id @result.expense.per_diem_expense&.per_diem_id
  json.name @result.expense.per_diem_name
  json.rate_value @result.expense.per_diem_rate_value
  json.quantity_value @result.expense.per_diem_quantity_value
end

json.date @result.expense.date.strftime("%d %b %Y")
json.formatted_date @result.expense.date.strftime("%Y-%m-%d")

json.amount do
  json.partial! 'shared/amount', amount: @result.expense.original_amount
end
json.reimbursable_amount do
  json.partial! 'shared/amount', amount: @result.expense&.reimbursable_amount
end

json.tds_slab do
  json.id @result.expense.tds_slab&.id
  json.name @result.expense.tds_slab&.name
  json.tds @result.expense.tds_slab&.tds
end

json.converted_amount do
  json.partial! 'shared/amount', amount: @result.expense.base_amount
end

json.converted @result.expense.converted?
json.conversion_rate @result.expense.conversion_rate

if @result.expense.card_expense?
  json.original_merchant_name @result.expense.card_expense&.card_transaction&.merchant_name
end

# flag to show whether a particular expense has been converted or not
json.converted @result.converted

json.per_diems @result.per_diems do |per_diem|
  json.id per_diem.id
  json.name "#{per_diem.configurable.name} - #{per_diem.name}"
  json.rate_value per_diem.rate_value
end

json.receipts @result.expense.receipts do |receipt|
  json.id receipt.id
  json.image do
    json.file_type receipt.file_format
    json.original receipt.image.url
    json.thumb receipt.image.url(:thumb)
  end
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
      json.card_number transaction.serial_id
    end
  end
end

if @result.expense.distance_expense?
  json.locations @result.expense.distance_expense.locations, :name, :address, :latitude, :longitude, :order, :maps_id
end

json.potential_duplicate @result.expense.has_duplicate_expenses?

# sending all the currencies and the respective symbols and codes
json.currencies do
  json.array!(Currency.all) do |currency|
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.id currency.id
  end
end

json.is_split @result.expense.is_split?
json.split_count @result.expense.split_count

# Tax Tracking Configuration

em_tax_tracking = @result.expense.user.company.feature_subscription.em_tax_tracking
json.config do
  json.em_tax_tracking em_tax_tracking
end

# Tax details for this expense
json.tax_details do
  json.merchant_gstin expense.gstin_location&.gstin
  json.merchant_state_id expense.gstin_location&.state_id
  json.merchant_registered_name expense.gstin_location&.gstin_master&.legal_name_of_business
  json.tax_amount expense.gst_amount&.value
  json.gst_type_id expense.gst_type_id
  json.merchant_bill_no expense.merchant_bill_no
  json.hsn_sac expense.hsn_sac
  json.state_of_expense_id expense.state_of_expense_id
  json.tax_rate_id expense.tax_rate_id
  json.gstin_location_id expense.gstin_location_id
end

json.tax_rates @result.tax_rates
json.state_codes @result.gst_state_codes