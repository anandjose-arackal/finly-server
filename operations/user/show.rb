class User::Show < User::Base
  attr_accessor :selected_user

  def pre_validate
    unless user.present?
      errors << 'User not found'
    end
  end

  def process
    if personal_view?
      self.selected_user = user
    else
      id = (params[:id] or params[:user_id])
      operation = User::Team::Index.new(user, params)
      result = operation.run
      if operation.is_success?
        self.selected_user = result.with_id(id).first rescue nil
        errors << 'User not found' if self.selected_user.blank?
      else
        errors << operation.errors
      end
    end
  end

  def success
    User::Show::Presenter.new(selected_user, params)
  end

  class User::Show::Presenter < BaseOperation::BasePresenter
    attr_accessor :team_mapping, :mapping, :policies, :roles, :company_managers, :company_finance_managers

    def initialize(user, params)
      super(user, params)
      self.roles = {admin: self.user.company_admin?, manager: self.user.manager?,
                    finance_manager: self.user.finance_manager?}
      self.team_mapping = self.user.team_mapping
      self.mapping = [retrieve_mapping(nil)]
      self.policies = user.policies
      self.policies.each do |policy|
        self.mapping << retrieve_mapping(policy)
      end
      company = user.company
      self.company_managers = company.managers
      self.company_finance_managers = company.finance_managers
    end

    private
    def retrieve_mapping(policy)
      policy_id = nil
      policy_id = policy.id if policy.present?
      company_default_mapping = team_mapping.policy(policy_id)
      default_mapping = company_default_mapping.default.first rescue nil
      conditional_manager = company_default_mapping.non_default.manager.first rescue nil
      conditional_finance_manager = company_default_mapping.non_default.finance_manager.first rescue nil
      conditional_approves_to = company_default_mapping.non_default.approves_to.first rescue nil
      conditional_approves_finance_to = company_default_mapping.non_default.approves_finance_to.first rescue nil
      { company_default: policy.nil?, policy: policy, default: default_mapping, conditional_manager: conditional_manager,
       conditional_finance_manager: conditional_finance_manager,
       conditional_approves_to: conditional_approves_to,
       conditional_approves_finance_to: conditional_approves_finance_to }
    end

  end
end