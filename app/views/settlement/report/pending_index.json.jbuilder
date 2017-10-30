json.array! @result.reports do |report|

  json.extract! report, :id, :name
  json.user do
    json.id report.user_id
    json.name report.user.name
    json.email report.user.email
    json.mobile_number report.user.mobile_number
  end
  json.final_approver do
    final_approver = report.final_approver
    if final_approver.present?
      json.name final_approver.name
      json.email final_approver.email
      json.mobile_number final_approver.mobile_number
    end
  end
  currency = Currency.first
  json.reimbursable_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: report.total_amount([:reimbursable]), currency: currency)
  end
  json.total_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: report.total_amount, currency: currency)
  end

end