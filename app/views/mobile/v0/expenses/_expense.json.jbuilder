json.extract! expense, :id, :date, :note, :report_id, :expense_type_id,
              :distance_value, :maps_distance_value, :time_value, :per_diem_name, :per_diem_rate_value, :per_diem_quantity_value,
              :distance_rate_value, :time_rate_value, :transcribed, :merchant_name, :reimbursable, :from_cash_on_hand
json.incomplete expense.incomplete?
if expense.distance_expense?
  json.distance_type expense.distance_expense&.type_id
  json.odometer_reading_start expense.distance_expense&.odometer_reading_start
  json.odometer_reading_end expense.distance_expense&.odometer_reading_end
  start_receipt = expense.distance_expense&.odometer_reading_receipt_start
  if start_receipt.present?
    json.odometer_reading_receipt_start do
      json.extract! start_receipt, :id, :user_id, :note, :created_at
      json.image_url do
        json.file_format start_receipt.file_format
        json.original start_receipt&.image(:original)
        json.large start_receipt&.image(:large)
        json.normal start_receipt&.image(:normal)
        json.thumb start_receipt&.image(:thumb)
      end
    end
  end
  end_receipt = expense.distance_expense&.odometer_reading_receipt_end
  if end_receipt.present?
    json.odometer_reading_receipt_end do
      json.extract! end_receipt, :id, :user_id, :note, :created_at
      json.image_url do
        json.file_format end_receipt.file_format
        json.original end_receipt&.image(:original)
        json.large end_receipt&.image(:large)
        json.normal end_receipt&.image(:normal)
        json.thumb end_receipt&.image(:thumb)
      end
    end
  end
end
json.user do
  json.id expense.user.id
  json.name expense.user.name
end
json.status do
  json.id expense.expense_status_id
  json.name expense.expense_status&.name
end

if expense.spent_from.present?
  json.pocket do
    json.pocket_name expense.spent_from&.name
    json.pocket_id expense.spent_from&.id
  end
end

json.cash_pockets do
  json.array!(expense.user.user_pockets.cash_and_credit_cards) do |pocket|
    if pocket.cash_pocket?
      adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
      json.balance adapter&.balance(display_balance: true)
      json.display_balance true
    elsif pocket.credit_card_pocket?
      # adapter = AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(pocket)
      json.balance 0
      json.display_balance false
    else
      adapter = nil
      json.can_claim_reimbursement false
    end
    json.can_claim_reimbursement expense.spent_from&.can_claim_reimbursement
    json.name pocket.name
    json.id pocket.id

    currency = pocket.base_currency
    json.base_currency do
      json.symbol currency&.symbol
      json.country_code currency&.country_code
      json.id currency&.id
    end
  end
end

json.amount do
  json.partial! 'api/v1/shared/amount', amount: expense.original_amount
end

json.original_amount do
  json.partial! 'api/v1/shared/amount', amount: expense.original_amount
end

json.converted_amount do
  json.partial! 'api/v1/shared/amount', amount: expense.base_amount
end

json.converted expense.converted?
json.conversion_rate expense.conversion_rate

json.type expense.expense_type_id
# if expense.manual_expense?
#   json.merchant_name expense.manual_expense.merchant_name
# elsif expense.card_expense?
#   json.merchant_name expense.card_expense.editable_merchant
# end
json.category do
  json.id expense.category.id
  json.name expense.category.name
end
json.receipts expense.receipts.each do |receipt|
  json.original receipt.image(:original)
  json.large receipt.image(:large)
  json.normal receipt.image(:normal)
  json.thumb receipt.image(:thumb)
end
if expense.distance_expense?
  json.locations expense.distance_expense.locations, :name, :address, :latitude, :longitude, :order, :maps_id
end
json.custom_fields do
  case expense.expense_type_id
    when ExpenseType.id_for(:manual)
      json.array! expense.manual_expense.custom_fields
    when ExpenseType.id_for(:card)
      json.array! expense.card_expense.custom_fields
    when ExpenseType.id_for(:distance)
      json.array! expense.distance_expense.custom_fields
    when ExpenseType.id_for(:time)
      json.array! expense.time_expense.custom_fields
    when ExpenseType.id_for(:per_diem)
      json.array! expense.per_diem_expense.custom_fields
  end
end
json.cancelled expense.cancelled?