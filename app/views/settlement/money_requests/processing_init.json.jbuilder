json.user_count @result.user_count
json.requests_total @result.request_total
json.details do
  json.array! @result.details do |detail|
    json.user detail[:user]
    json.requests_total detail[:total]
    money_requests = detail[:money_requests]
    json.money_requests_count money_requests.size
    json.money_requests do
      json.array! money_requests do |money_request|
        json.extract! money_request, :id, :name, :policy
        json.submitted_at DateUtils.date_formatted money_request.submitted_at
        json.required_by_date DateUtils.date_formatted money_request.required_by_date
        json.approved_at DateUtils.date_formatted money_request.approved_at
        final_approver = money_request.final_approver
        json.auto_approved final_approver.blank?
        json.final_approver final_approver
        json.request_total money_request.total_amount
      end
    end
    json.bank_accounts detail[:bank_accounts]
    json.reimbursement_cards detail[:reimbursement_cards]
    json.has_error detail[:has_error]
    json.errors detail[:errors]
  end
end