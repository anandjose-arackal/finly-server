class PolicyUserRoleMappings::Index < PolicyUserRoleMappings::Base
  attr_accessor :policy_user_role_mappings

  def validate
    unless self.policy.present?
      add_message :error, 'Policy not found'
    end
  end

  def process
    self.policy_user_role_mappings = self.policy.policy_user_role_mappings
  end

  class PolicyUserRoleMappings::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :policy_user_role_mappings

    has_scope :filter_role_id

    def init
      self.policy_user_role_mappings = params[:policy_user_role_mappings]
      self.policy_user_role_mappings = apply_scope(self.policy_user_role_mappings, params)
    end
  end
end