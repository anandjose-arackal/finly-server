json.result do
  json.merge! @op['model'].as_json
  json.reviewal_chain @op['model']&.get_reviewal_chain
  json.tabs @op['result']['tabs']

  json.customer_fields do
    json.array! (0..4).to_a do |j|
      json.set! "customer_param_key_#{j + 1}", @op['model'].send("customer_param_key_#{j + 1}")
      json.key_label "customer_param_key_#{j + 1}"
      json.index j + 1
      json.set! "customer_param_value_#{j + 1}", @op['model'].send("customer_param_value_#{j + 1}")
      json.value_label "customer_param_value_#{j + 1}"
    end
  end
end