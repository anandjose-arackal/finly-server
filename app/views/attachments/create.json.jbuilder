json.results do
  json.attachment do
    json.merge! @result.attachment.as_json
  end
end