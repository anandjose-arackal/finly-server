json.user_count @result.user_count
json.requests_total @result.request_total
json.details do
  json.array! @result.details do |detail|
    json.user do
      user = detail[:user]
      json.id user.id
      json.name user.name
      json.email user.email
      json.mobile_number user.mobile_number
    end
    json.requests_total detail[:total]
    money_requests = detail[:money_requests]
    json.money_requests_count money_requests.size
    json.money_requests do
      json.array! money_requests do |money_request|
        json.extract! money_request, :id, :name, :policy, :date_as_string
        json.submitted_on DateUtils.date_formatted(report.submitted_at)
        json.approved_on DateUtils.date_formatted(report.approved_at)
        final_approver = money_request.final_approver
        json.auto_approved final_approver.blank?
        json.final_approver do
          json.name final_approver&.name
          json.email final_approver&.email
          json.mobile_number final_approver&.mobile_number
        end
        json.request_total money_request.total_amount
      end
    end
    json.bank_accounts detail[:bank_accounts]
    json.reimbursement_cards detail[:reimbursement_cards]
    json.has_error detail[:has_error]
    json.errors detail[:errors]
  end
end