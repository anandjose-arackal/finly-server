if @op.success?
  json.result do
    json.merge! @op['result']['data'].as_json["table"]
  end
end