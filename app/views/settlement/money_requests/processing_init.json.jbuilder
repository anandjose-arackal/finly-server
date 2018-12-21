json.user_count @result.user_count
json.requests_total @result.request_total.values
json.details do
  json.array! @result.details do |detail|
    json.user detail[:user]
    json.requests_total detail[:request_total]
    money_requests = detail[:money_requests]
    json.money_requests_count money_requests.size
    json.money_requests do
      json.array! money_requests do |money_request|
        json.extract! money_request, :id, :name, :policy
        json.submitted_on DateUtils.date_formatted money_request.submitted_at
        json.required_by_date DateUtils.date_formatted money_request.required_by_date
        json.approved_on DateUtils.date_formatted money_request.approved_at
        final_approver = money_request.final_approver
        json.auto_approved final_approver.blank?
        json.final_approver final_approver
        json.request_total do
          json.value money_request.total_amount
          json.currency money_request.base_currency
        end
      end
    end
    json.bank_accounts detail[:bank_accounts]
    json.expense_cards detail[:expense_cards]
    json.has_error detail[:has_error]
    json.errors detail[:errors]
  end
end