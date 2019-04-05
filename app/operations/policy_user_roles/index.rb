class PolicyUserRoles::Index < PolicyUserRoles::Base
  attr_accessor :policy_user_roles, :user_roles

  def validate
    unless self.policy.present?
      add_message :error, 'Policy not found'
    end
  end

  def process
    self.policy_user_roles = self.policy.policy_user_roles
    self.user_roles = UserRole.all 
  end

  def success
    params[:policy_user_roles] = self.policy_user_roles
    # Currently all roles are shown
    params[:user_roles] = self.user_roles
    PolicyUserRoles::Index::IndexPresenter.new(user, params, messages)
  end

  class PolicyUserRoles::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policy_user_roles, :user_roles, :paginated_policy_user_roles
    include HasScope

    has_scope :filter_role_id

    def init
      self.policy_user_roles = params[:policy_user_roles]
      self.policy_user_roles = apply_scopes(self.policy_user_roles, params)

      page = params[:page] || 1
      per_page = params[:per_page] || 10000 # hardcoded as pagination on frontend is not there

      self.paginated_policy_user_roles = self.policy_user_roles.paginate(page: page, per_page: per_page).includes_for_index
      self.user_roles = params[:user_roles]
    end
  end
end