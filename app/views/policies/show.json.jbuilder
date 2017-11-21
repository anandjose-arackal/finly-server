json.name @result.policy.name
json.policy_admin (current_user.policy_admin?(@result.policy) or current_user.admin?) && params[:view] == 'admin'
json.description @result.policy.description
