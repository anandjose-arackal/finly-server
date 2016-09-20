json.company do
  json.id current_company.id
  json.name current_company.name
  json.current_user_id current_user.id
end
# [:team_managers, :team_finance_managers, :team_admins, :team_policies].each do |key|
[:team_managers, :team_finance_managers, :team_policies].each do |key|
  json.set! key, @result.send(key).each do |manager|
    json.id manager.id
    json.name manager.name
  end
end