json.partial! 'expense', expense: @result.expense
json.currencies do
  json.array!(Currency.all) do |currency|
    json.country currency.country
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.id currency.id
  end
end
json.tax_details do
  json.merchant_gstin expense.gstin_location.gstin
  json.merchant_state_id expense.gstin_location.state_id
  json.tax_amount expense.gst_amount&.value
  json.gst_type_id expense.gst_type_id
  json.merchant_bill_no expense.merchant_bill_no
  json.hsn_sac expense.hsn_sac
  json.state_of_expense_id expense.state_of_expense_id
end