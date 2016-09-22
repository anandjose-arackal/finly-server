json.company do
  json.id current_company.id
  json.name current_company.name
  json.current_user_id @result.user.id
  json.roles do
    json.admin @result.user.company_admin?
    json.manager @result.user.manager?
    json.finance_manager @result.user.finance_manager?
  end
end
[:team_managers, :team_finance_managers, :team_admins, :team_policies].each do |key|
# [:team_managers, :team_finance_managers, :team_policies].each do |key|
  json.set! key, @result.send(key).each do |manager|
    json.id manager.id
    json.name manager.name
  end
end