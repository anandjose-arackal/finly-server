class User::Show < User::Base
  attr_accessor :selected_user, :card

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
        if self.selected_user.blank?
          add_message :error, 'User not found'
        elsif self.selected_user.cards.present?
          self.card = ItzCash::AccountDetails.(selected_user).card rescue nil
        end
      else
        messages[:error] = operation.messages[:error]
      end
    end
  end

  def success
    params[:selected_user] = selected_user
    params[:card] = card
    User::Show::Presenter.new(user, params, messages)
  end

  class User::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :team_mapping, :mapping, :policies, :roles, :company_managers,
                  :company_finance_managers, :company_admins, :company_policies,
                  :actions, :team, :team_managers, :team_finance_managers, :team_policies,
                  :team_members_presenter, :selected_user, :mapping_editable, :wallet, :card

    def init
      self.selected_user = params[:selected_user]
      self.roles = {admin: self.selected_user.company_admin?, manager: self.selected_user.manager?,
                    finance_manager: self.selected_user.finance_manager?}
      self.team_mapping = self.selected_user.team_mapping
      self.mapping = [Policy::Mappings::Show.(user, user: selected_user, policy: nil).map]
      self.policies = selected_user.policies
      self.policies.each do |policy|
        self.mapping << Policy::Mappings::Show.(user, user: selected_user, policy: policy).map
      end
      self.actions = load_actions
      self.mapping_editable = user.company_admin?
      self.wallet = self.selected_user.wallet
      self.card = params[:card]
    end

    private
    # def retrieve_mapping(policy)
    #   policy_id = policy.id rescue nil
    #   company_default_mapping = team_mapping.policy(policy_id)
    #   default_mapping = company_default_mapping.default
    #   conditional_manager = company_default_mapping.non_default.manager
    #   conditional_finance_manager = company_default_mapping.non_default.finance_manager
    #   conditional_approves_to = company_default_mapping.non_default.approves_to
    #   conditional_approves_finance_to = company_default_mapping.non_default.approves_finance_to
    #   {company_default: policy.nil?, policy: policy, default: default_mapping,
    #    conditional_manager: conditional_manager,
    #    conditional_finance_manager: conditional_finance_manager,
    #    conditional_approves_to: conditional_approves_to,
    #    conditional_approves_finance_to: conditional_approves_finance_to}
    # end

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

      card_assigned = self.selected_user.cards.present?

      credit_params = {}
      credit_params[:view] = params[:view]
      credit_params[:action_type] = User::Wallet::Base::ACTIONS[:credit]
      credit_params[:to_user_id] = selected_user.id

      debit_params = {}
      debit_params[:view] = params[:view]
      debit_params[:action_type] = User::Wallet::Base::ACTIONS[:debit]
      debit_params[:from_user_id] = selected_user.id

      # Wallet Actions
      if manager_view? or finance_view? or admin_view?
        if admin_view?
          # Virtual Account -> Wallet
          credit_params[:from_account] = :virtual_account
          credit_params[:to_account] = :wallet
          actions[:credit_wallet_from_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

          if card_assigned
            # Virtual Account -> Card
            credit_params[:from_account] = :virtual_account
            credit_params[:to_account] = :card
            actions[:credit_card_from_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(credit_params)
          end

          # Wallet -> Virtual Account
          debit_params[:from_account] = :wallet
          debit_params[:to_account] = :virtual_account
          actions[:debit_wallet_to_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(debit_params)
        end
        if selected_user != user
          # Wallet -> Wallet
          credit_params[:from_account] = :wallet
          credit_params[:to_account] = :wallet
          actions[:credit_wallet_from_wallet] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

          # Wallet -> Wallet
          debit_params[:from_account] = :wallet
          debit_params[:to_account] = :wallet
          actions[:debit_wallet_to_wallet] = Rails.application.routes.url_helpers.update_balance_path(debit_params)
        end
      end

      if card_assigned
        # Wallet -> Card
        credit_params[:from_account] = :wallet
        credit_params[:to_account] = :card
        actions[:credit_card_from_wallet] = Rails.application.routes.url_helpers.update_balance_path(credit_params)
        # Wallet Actions End


        # Card Actions
        card = self.selected_user.cards.first
        if manager_view? or finance_view? or admin_view?
          card_params = {}
          card_params[:view] = params[:view]
          card_params[:user_id] = selected_user.id
          card_params[:action_type] = nil
          if card.active
            card_params[:status_type] = User::PrepaidCard::Base::STATUS[:block]
            actions[:deactivate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
          else
            card_params[:status_type] = User::PrepaidCard::Base::STATUS[:unblock]
            actions[:activate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
          end
        else
          if card.active
            card_params = {status_type: User::PrepaidCard::Base::STATUS[:block], user_id: selected_user.id}
            actions[:deactivate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
          else
            if card.disabled_by_role_id == UserRole.id_for(:employee)
              card_params = {status_type: User::PrepaidCard::Base::STATUS[:unblock], user_id: selected_user.id}
              actions[:activate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
            end
          end
        end
      end
      actions
    end

  end
end
