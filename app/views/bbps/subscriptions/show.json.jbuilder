json.result do
  json.merge! @op['model'].as_json
  json.reviewal_chain @op['model']&.get_reviewal_chain
  json.tabs @op['result']['tabs']

  biller_customer_params = @op['model'].biller&.biller_customer_params

  json.customer_fields do
    json.array! (0..4).to_a do |j|

      json.set! "customer_param_key_#{j + 1}", @op['model'].send("customer_param_key_#{j + 1}")
      json.key_label "customer_param_key_#{j + 1}"
      json.index j + 1
      json.set! "customer_param_value_#{j + 1}", @op['model'].send("customer_param_value_#{j + 1}")
      json.value_label "customer_param_value_#{j + 1}"

      if biller_customer_params[j].present?
        json.display true
        json.merge! biller_customer_params[j]
      else
        json.display false
      end
    end
  end
end