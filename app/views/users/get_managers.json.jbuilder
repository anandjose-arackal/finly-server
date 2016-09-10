json.company do
  json.id current_company.id
  json.name current_company.name

end
[:company_managers, :company_finance_managers, :company_admins, :company_policies].each do |key|
  json.set! key, @result.send(key).each do |manager|
    json.id manager.id
    json.name manager.name
  end
end