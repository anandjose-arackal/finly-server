json.result do
    json.policies do
      json.merge! @result.admin_policies.as_json
    end
    json.role_groups do
      json.merge! @result.role_groups
    end
end