json.policies do
  json.array! @result.policies do |policy|
    json.extract! policy, :id, :name, :default
    json.roles do
      json.array! policy.policy_user_roles do |pur|
        json.role pur.user_role.name
      end
    end
  end 
end