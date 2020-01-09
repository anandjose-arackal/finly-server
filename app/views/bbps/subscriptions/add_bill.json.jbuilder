if @op.success?
  json.bill_id @op['result']['bill']&.id
end