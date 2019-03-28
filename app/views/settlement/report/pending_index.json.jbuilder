json.array! @result.paginated_reports do |report|

  json.extract! report, :id, :policy, :date_as_string
  json.name "#{report.id} - #{report.name}"
  json.submitted_on DateUtils.date_formatted(report.submitted_at)
  json.approved_on DateUtils.date_formatted(report.approved_at)
  json.user report.user
  json.final_approver report.final_approver
  currency = report.settlement_currency
  json.reimbursable_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: report.reimbursable_expenses(currency_code: currency.country_code), currency: currency)
  end
  json.total_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: report.total_amount([], currency_code: currency.country_code), currency: currency)
  end

end