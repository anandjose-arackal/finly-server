json.company do
  json.id current_company.id
  json.name current_company.name

end
[:team_managers, :team_finance_managers, :team_admins, :team_policies].each do |key|
  json.set! key, @result.send(key).each do |manager|
    json.id manager.id
    json.name manager.name
  end
end