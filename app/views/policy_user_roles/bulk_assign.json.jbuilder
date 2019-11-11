if @result.respond_to?(:unassignable_roles)
	json.unassignable_roles do
		json.array!(@result.unassignable_roles) do |role|
			json.policy_id role.policy_id rescue nil
			json.user_id role.user_id rescue nil
			json.user_role_id role.user_role_id rescue nil			
		end
	end
end
