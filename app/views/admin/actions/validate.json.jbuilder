json.data do
  json.valid_action @op.success?
  json.records @op[:records]
end