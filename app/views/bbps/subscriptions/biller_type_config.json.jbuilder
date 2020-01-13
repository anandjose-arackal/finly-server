json.success @op.success?

json.result do
  json.fields @op['result']['fields']
end
