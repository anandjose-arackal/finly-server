json.result do
  json.merge! @op['model'].as_json

  json.reviewal_chain @result.purchase_order.get_reviewal_chain
end