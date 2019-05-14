json.non_reimbursable_expenses_total @result.non_reimbursable_expenses_total
json.reimbursable_expenses_total @result.reimbursable_expenses_total
json.card_expenses_total @result.card_expenses_total
json.currency_symbol @result.report.base_currency_symbol
json.currency_country_code @result.report.base_currency_code

json.total @result.report.total_amount
json.base_currency_id @result.report.base_currency_id
json.date @result.report.created_at.strftime('%d %b %Y')

json.violations do
  json.blocking_present @result.has_blocking?
  json.warning_present @result.has_warning?
  json.blocking_messages @result.blocking_array
  json.warning_messages @result.warning_array
end