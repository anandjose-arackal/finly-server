json.success @op.success?

json.result do
  json.fields do
    json.array! @op['result']['model']&.biller_customer_params
  end
end
