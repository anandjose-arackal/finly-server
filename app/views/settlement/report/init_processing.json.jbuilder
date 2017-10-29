json.user_count @result.user_count
json.expenses_total @result.expenses_total
json.reimbursement_total @result.reimbursement_total
json.details do
  json.array! @result.details do |detail|
    json.user do
      user = detail[:user]
      json.name user.name
      json.email user.email
      json.mobile_number user.mobile_number
    end
    json.expenses_total detail[:expenses_total]
    json.reimbursement_total detail[:reimbursement_total]
    json.expenses_total detail[:expenses_total]
    reports = detail[:reports]
    json.reports_count reports.size
    json.reports do
      json.array! reports do |report|
        json.name report.name
        final_approver = report.final_approver
        json.auto_approved final_approver.blank?
        json.final_approver do
          json.name final_approver&.name
          json.email final_approver&.email
          json.mobile_number final_approver&.mobile_number
        end
        json.expenses_total report.total_amount
        json.reimbursement_total report.total_amount([:reimbursable])
      end
    end
    json.bank_accounts detail[:bank_accounts]
    json.reimbursement_cards detail[:reimbursement_cards]
    json.has_error detail[:has_error]
    json.errors detail[:errors]
  end
end