if @result.respond_to?(:unassignable_roles)
	json.unassignable_roles do
		json.array!(@result.unassignable_roles) do |role|
			json.policy role[:policy] rescue nil
			json.user role[:user] rescue nil
			json.user_role role[:user_role] rescue nil			
		end
	end
end
