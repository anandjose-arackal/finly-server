class User::Show < User::Base
  attr_accessor :selected_user

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
  end

  def process
    id = (params[:id] or params[:user_id])
    if personal_view? or id == user.id
      self.selected_user = user
    else
      operation = User::Team::Index.new(user, params)
      result = operation.run
      if operation.success?
        self.selected_user = result.with_id(id).first rescue nil
        add_message :error, 'User not found' if self.selected_user.blank?
      else
        messages[:error] = operation.messages[:error]
      end
    end
  end

  def success
    params[:selected_user] = selected_user
    User::Show::Presenter.new(user, params, messages)
  end

  class User::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :team_mapping, :mapping, :policies, :roles, :company_managers,
                  :company_finance_managers, :company_admins, :company_policies,
                  :actions, :team, :team_managers, :team_finance_managers, :team_policies,
                  :team_members_presenter, :selected_user, :mapping_editable

    def init
      self.selected_user = params[:selected_user]
      self.roles = {admin: self.selected_user.company_admin?, manager: self.selected_user.manager?,
                    finance_manager: self.selected_user.finance_manager?}
      self.team_mapping = self.selected_user.team_mapping
      self.mapping = [retrieve_mapping(nil)]
      self.policies = selected_user.policies
      self.policies.each do |policy|
        self.mapping << retrieve_mapping(policy)
      end
      self.actions = load_actions
      self.mapping_editable = user.company_admin?
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
      {company_default: policy.nil?, policy: policy, default: default_mapping,
       conditional_manager: conditional_manager,
       conditional_finance_manager: conditional_finance_manager,
       conditional_approves_to: conditional_approves_to,
       conditional_approves_finance_to: conditional_approves_finance_to}
    end

    def get_managers

    end

    def load_actions
      actions = {}
      # Check if user has a already signed up, if not give option to delete/resend invite
      if self.selected_user.invitation_token.present? and self.selected_user.invitation_accepted_at.blank?
        actions[:delete_invite] = Rails.application.routes.url_helpers.pending_invite_path(id: self.selected_user.id)
        actions[:resend_invite] = Rails.application.routes.url_helpers.pending_invite_path(id: self.selected_user.id)
      else
        # If user has signed up and is not viewing themselves
        if self.selected_user.active and selected_user.id != user.id
          actions[:deactivate] = Rails.application.routes.url_helpers.user_path(id: self.selected_user.id)
        elsif !selected_user.active and selected_user.id != user.id
          actions[:activate] = Rails.application.routes.url_helpers.user_path(id: self.selected_user.id)
        end
      end
      actions
    end

  end
end
