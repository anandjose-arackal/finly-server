class User::Show < User::Base
  attr_accessor :selected_user

  def pre_validate
    unless user.present?
      messages[:error] << 'User not found'
    end
  end

  def process
    if personal_view?
      self.selected_user = user
    else
      id = (params[:id] or params[:user_id])
      operation = User::Team::Index.new(user, params)
      result = operation.run
      if operation.success?
        self.selected_user = result.with_id(id).first rescue nil
        messages[:error] << 'User not found' if self.selected_user.blank?
      else
        messages[:error] << operation.errors
      end
    end
  end

  def success
    User::Show::Presenter.new(selected_user, params)
  end

  class User::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :team_mapping, :mapping, :policies, :roles, :company_managers,
                  :company_finance_managers, :company_admins, :company_policies,
                  :actions

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
      self.company_admins = company.admins
      self.company_policies = company.policies
      self.actions = load_actions
    end

    private
    def retrieve_mapping(policy)
      policy_id = policy.id rescue nil
      company_default_mapping = team_mapping.policy(policy_id)
      default_mapping = company_default_mapping.default
      conditional_manager = company_default_mapping.non_default.manager
      conditional_finance_manager = company_default_mapping.non_default.finance_manager
      conditional_approves_to = company_default_mapping.non_default.approves_to
      conditional_approves_finance_to = company_default_mapping.non_default.approves_finance_to
      {company_default: policy.nil?, policy: policy, default: default_mapping, conditional_manager: conditional_manager,
       conditional_finance_manager: conditional_finance_manager,
       conditional_approves_to: conditional_approves_to,
       conditional_approves_finance_to: conditional_approves_finance_to}
    end

    def load_actions
      actions = {}
      # Check if user has a already signed up, if not give option to delete/resend invite
      if self.user.invitation_token.present? and self.user.invitation_accepted_at.blank?
        actions[:delete_invite] = Rails.application.routes.url_helpers.pending_invite_path(id: self.user.id)
        actions[:resend_invite] = Rails.application.routes.url_helpers.pending_invite_resend_path(pending_invite_id: self.user.id)
      else
        # If user has signed up
        if self.user.active
          actions[:deactivate] = Rails.application.routes.url_helpers.edit_pending_invite_path(id: self.user.id)
        else
          actions[:activate] = Rails.application.routes.url_helpers.edit_pending_invite_path(id: self.user.id)
        end
      end
      actions
    end

  end
end