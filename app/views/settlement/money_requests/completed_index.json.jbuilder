json.array! @result.paginated_money_requests do |money_request|

  json.extract! money_request, :id
  json.name "#{money_request.id} - #{money_request.name}"
  json.user do
    json.id money_request.user_id
    json.name money_request.user.name
    json.email money_request.user.email
    json.mobile_number money_request.user.mobile_number
  end
  json.final_approver do
    final_approver = money_request.final_approver
    if final_approver.present?
      json.name final_approver.name
      json.email final_approver.email
      json.mobile_number final_approver.mobile_number
    end
  end
  json.payment do
    mapping = money_request.money_request_processor_mapping
    processor_group = mapping&.processor
    processed_by = processor_group&.created_by_user

    json.completed_on DateUtils.datetime_formatted mapping&.completed_at
    json.amount mapping&.amount
    json.payment_type processor_group&.payment_type
    json.payment_mode processor_group&.payment_mode

    if processed_by.present?
      json.processed_by do
        json.name processed_by.name
        json.email processed_by.email
        json.mobile_number processed_by.mobile_number
      end
    else
      json.processed_by nil
    end
  end

  currency = money_request.base_currency
  json.total_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: money_request.total_amount, currency: currency)
  end

end