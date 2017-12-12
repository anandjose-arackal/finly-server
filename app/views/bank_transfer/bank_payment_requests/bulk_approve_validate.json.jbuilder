json.array!(@result.validate_result) do |result|
  json.user result[:user]
  json.amount result[:amount]
  json.errors result[:errors]
  json.valid result[:valid]
  json.name result[:name]
end