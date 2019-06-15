json.result do
  json.policies do
    json.merge! @result.admin_policies.as_json
  end
  json.role_groups do
    json.merge! @result.role_groups
  end
  json.company do
    json.id @result.company.id
    json.name @result.company.name
    json.current_user_id @result.user.id
  end
end