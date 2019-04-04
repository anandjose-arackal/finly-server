# json.result do
#   json.policy_user_roles do
#     json.array! @result.policy_user_roles do |pur|
#       # json.id pur.id, 
#       json.extract! pur, :id, :min_amount, :max_amount, :user_role_id
#       json.merge! pur.user.as_json
#     end
#   end
#   # json.user_roles do
#   #   json.array!(@result.user_roles) do |user_role|
#   #     json.merge! user_role.as_json
#   #   end
#   # end
# end

json.array! @result.paginated_policy_user_roles do |pur|
  # json.id pur.id, 
  json.extract! pur, :id, :min_amount, :max_amount
  json.merge pur.user.as_json
end
