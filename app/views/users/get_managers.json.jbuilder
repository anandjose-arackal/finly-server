[:company_managers, :company_finance_managers].each do |key|
  json.set! key, @result.send(key).each do |manager|
    json.id manager.id
    json.name manager.name
    json.email manager.email
  end
end