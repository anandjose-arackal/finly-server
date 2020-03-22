json.user_count @result.user_count
json.expenses_total @result.expenses_total&.values
json.reimbursement_total @result.reimbursement_total&.values
json.details do
  json.array! @result.details do |detail|
    json.user do
      user = detail[:user]
      json.id user.id
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
        json.extract! report, :id, :name, :policy, :date_as_string
        json.submitted_on DateUtils.date_formatted(report.submitted_at)
        json.approved_on DateUtils.date_formatted(report.approved_at)
        #final_approver = report.final_approver
        json.auto_approved false
        json.final_approver do
          json.name "test"
          json.email "test"
          json.mobile_number "test"
        end
        json.expenses_total report.total_amount
        json.reimbursement_total report.reimbursable_expenses
      end
    end
    json.bank_accounts detail[:bank_accounts]
    json.reimbursement_cards detail[:reimbursement_cards]
    json.has_error detail[:has_error]
    json.errors detail[:errors]
  end
end