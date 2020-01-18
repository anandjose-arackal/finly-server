class Insights::Resolver < Transactions::Resolver::Scope

  def resolve(user, params)
    # Conditions:
    # :company
    # :user
    # :policy
    # :policy_user_role
    # :app

    company = user.company
    policy_role_map = {} # used for holding all combination of policies and roles
    policies = []
    roles = []
    user.policy_user_roles&.each do |m|
      (policy_role_map[m.policy_id] ||= []) << m.user_role_id
      policies << m.policy_id
      roles << m.user_role_id
    end
    app = RequestStoreUtil.current_app

    # scope = self.scope.where(application: app)
    query = "application = \"#{app}\" AND ("

    # All blank
    # collection = scope.where(company_id: nil, user_id: nil, policy_id: nil, user_role_id: nil)
    query += "(company_id IS NULL AND user_id IS NULL and policy_id IS NULL and user_role_id IS NULL)"

    # only with company
    # collection = collection.or(scope.where(company_id: company.id, user_id: nil, policy_id: nil, user_role_id: nil))
    query += " OR (company_id = #{company.id} AND user_id IS NULL and policy_id IS NULL and user_role_id IS NULL)"

    # user
    # collection = collection.or(scope.where(company_id: company.id, user_id: user.id, policy_id: nil, user_role_id: nil))
    query += " OR (company_id = #{company.id} AND user_id = #{user.id} and policy_id IS NULL and user_role_id IS NULL)"

    # nil user + policy + nil role
    query += " OR (company_id = #{company.id} AND user_id IS NULL and policy_id IN (#{policies.join(',')}) and user_role_id IS NULL)"
    # policies.each do |policy|
    #   collection = collection.or(scope.where(company_id: company.id, user_id: nil, policy_id: policy, user_role_id: nil))
    # end

    # nil user + nil policy + role
    query += " OR (company_id = #{company.id} AND user_id IS NULL and policy_id IS NULL and user_role_id IN (#{roles.join(',')}))"
    # roles.each do |role|
    #   collection = collection.or(scope.where(company_id: company.id, user_id: nil, policy_id: nil, user_role_id: role))
    # end

    # nil user + policy + role
    policy_role_map.each do |policy_id, role_ids|
      # collection = collection.or(scope.where(company_id: company.id, user_id: nil, policy_id: policy_id, user_role_id: role_ids))
      query += " OR (company_id = #{company.id} AND user_id is NULL and policy_id = #{policy_id} and user_role_id IN (#{role_ids.join(',')}))"
    end
    query += ")"

    Success(self.scope.where(query))
  end
end