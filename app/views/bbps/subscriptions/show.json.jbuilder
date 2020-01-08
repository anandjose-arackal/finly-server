json.result do
  json.merge! @op['model'].as_json
  json.reviewal_chain @op['model']&.get_reviewal_chain
  json.tabs @op['result']['tabs']

  biller_customer_params = @op['model'].biller&.biller_customer_params
end