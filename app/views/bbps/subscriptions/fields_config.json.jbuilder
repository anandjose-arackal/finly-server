json.result do
  json.types do
    json.array! @result[:output][:types]
  end
end