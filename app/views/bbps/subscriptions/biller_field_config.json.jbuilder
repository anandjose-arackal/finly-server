json.success @op.success?

json.result do
  biller_customer_params = @op['result']['model']&.biller_customer_params
  json.fields do
    json.array! (0..4).to_a do |j|
      if biller_customer_params[j].present?
        json.set! "customer_param_key_#{j + 1}", biller_customer_params[j]['param_name']
        json.merge! biller_customer_params[j]
      end
    end
  end
end
