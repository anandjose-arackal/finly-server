json.array! @result.policy_user_roles do |purm|
  json.id purm.id
  json.merge purm.user.as_json
end