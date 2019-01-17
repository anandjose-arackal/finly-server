json.array! @result.policy_user_role_mappings do |purm|
  json.id purm.id
  json.merge purm.user.as_json
end