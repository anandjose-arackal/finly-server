if @op.success?
  json.result do
    json.amount @op['result']['data']["amount"].to_f / 100
    json.convenience_fee @op['result']['data']["convenience_fee"].to_f / 100
    json.late_payment_fee @op['result']['data']["late_payment_fee"].to_f / 100
    json.early_payment_fee @op['result']['data']["early_payment_fee"].to_f / 100
    json.merge! @op['result']['data'].as_json["table"].except("amount", "convenience_fee", "late_payment_fee", "early_payment_fee")
  end
  if @op['result']['bill'].present?
    json.bill @op['result']['bill'].as_json
  end
end