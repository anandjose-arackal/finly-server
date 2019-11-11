class Insights::Resolver < Transactions::Resolver::Scope

  def load(params)
    # Conditions:
    # :company
    # :user
    # :policy
    # :policy_user_role
    # :app

    company = @user.company
    policy_role_map = {} # used for holding all combination of policies and roles
    policies = []
    roles = []
    user.policy_user_roles&.each do |m|
      (policy_role_map[m.policy_id] ||= []) << m.user_role_id
      policies << m.policy_id
      roles << m.user_role_id
    end
    app = RequestStoreUtil.current_app

    scope = self.scope.where(application: app)

    # All blank
    collection = scope.where(company_id: nil, user_id: nil, policy_id: nil, user_role_id: nil)

    # only with company
    collection = collection.or(scope.where(company_id: company.id, user_id: nil, policy_id: nil, user_role_id: nil))

    # user
    collection = collection.or(scope.where(company_id: company.id, user_id: nil, policy_id: nil, user_role_id: nil))

    # nil user + policy + nil role
    policies.each do |policy|
      collection = collection.or(scope.where(company_id: company.id, user_id: nil, policy_id: policy, user_role_id: nil))
    end

    # nil user + nil policy + role
    roles.each do |role|
      collection = collection.or(scope.where(company_id: company.id, user_id: nil, policy_id: nil, user_role_id: role))
    end

    # nil user + policy + role
    policy_role_map.each do |policy_id, role_ids|
      collection = collection.or(scope.where(company_id: company.id, user_id: nil, policy_id: policy_id, user_role_id: role_ids))
    end

    collection
  end
end