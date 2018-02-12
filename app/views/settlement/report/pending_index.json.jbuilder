json.array! @result.paginated_reports do |report|

  json.extract! report, :id, :name, :policy, :date_as_string
  json.submitted_on DateUtils.date_formatted(report.submitted_at)
  json.approved_on DateUtils.date_formatted(report.approved_at)
  json.user report.user
  json.final_approver report.final_approver
  currency = Currency.first
  json.reimbursable_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: report.total_amount([:reimbursable]), currency: currency)
  end
  json.total_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: report.total_amount, currency: currency)
  end

end