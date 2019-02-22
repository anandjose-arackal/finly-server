json.array! @result.policy_user_roles do |purm|
  # json.id purm.id, 
  json.extract! purm, :id, :min_amount, :max_amount
  json.merge purm.user.as_json
end