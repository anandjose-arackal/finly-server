json.success @op.success?

json.result do
  biller_customer_params = @op['result']['model']&.biller_customer_params

  json.fields do
    json.array! 5.times do |j|
      json.set! "customer_param_key_#{j + 1}", biller_customer_params[j]&.dig('param_name')
      json.key "customer_param_key_#{j + 1}"
      json.index j + 1
      if biller_customer_params[j].present?
        json.display true
        json.merge! biller_customer_params[j]
      else
        json.display false
      end
    end
  end
  json.fetch_requirement @op['result']['fetch_requirement']
  json.support_bill_validation @op['result']['support_bill_validation']

end
