json.permissions do
  @result.permissions.each do |k, v|
    json.set! k, v
  end
end