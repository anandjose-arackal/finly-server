json.payments do
  json.array!(@result.errors) do |result|
    json.account_number result[:account_number]
    json.ifsc result[:ifsc]
    json.name result[:name]
    json.note result[:note]
    json.errors result[:errors]
  end
end