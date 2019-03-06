class PolicyUserRoles::Index < PolicyUserRoles::Base
  attr_accessor :policy_user_roles

  def validate
    unless self.policy.present?
      add_message :error, 'Policy not found'
    end
  end

  def process
    self.policy_user_roles = self.policy.policy_user_roles
  end

  def success
    params[:policy_user_roles] = self.policy_user_roles
    PolicyUserRoles::Index::IndexPresenter.new(user, params, messages)
  end

  class PolicyUserRoles::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policy_user_roles
    include HasScope

    has_scope :filter_role_id

    def init
      self.policy_user_roles = params[:policy_user_roles]
      self.policy_user_roles = apply_scopes(self.policy_user_roles, params)
    end
  end
end