class User::Show < User::Base
  attr_accessor :selected_user, :card_presenter

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
          self.card_presenter = ItzCash::AccountDetails.(selected_user) rescue nil
        end
      else
        messages[:error] = operation.messages[:error]
      end
    end
  end

  def success
    params[:selected_user] = selected_user
    params[:card_presenter] = card_presenter
    User::Show::Presenter.new(user, params, messages)
  end

  class User::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :team_mapping, :mapping, :policies, :roles, :company_managers,
                  :company_finance_managers, :company_admins, :company_policies,
                  :actions, :team, :team_managers, :team_finance_managers, :team_policies,
                  :team_members_presenter, :selected_user, :mapping_editable, :wallet, :card,
                  :periods, :auto_submit_config, :mcc_groups, :card_limit, :card_periods, :card_limits, :card_restriction

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
      self.card = params[:card_presenter].card rescue nil
      self.auto_submit_config = self.selected_user.auto_submit_config
      self.periods = Period.all
      self.card_periods = Period.limit(3)
      self.mcc_groups = MccGroup.all
      self.card_limit = params[:card_presenter].available_card_eligibility rescue nil
      selected_card = selected_user.cards.first rescue nil
      self.card_restriction = selected_card.card_restriction rescue nil
      self.card_limits = card_restriction.card_limits rescue nil
    end

    private

    def get_managers

    end

    def load_actions
      actions = {}
      # Check if user has a already signed up, if not give option to delete/resend invite
      if (self.selected_user.invitation_token.present? and self.selected_user.invitation_accepted_at.blank?) or
        (selected_user.first_name.blank?)
        actions[:delete_invite] = Rails.application.routes.url_helpers.pending_invite_path(id: self.selected_user.id)
        actions[:resend_invite] = Rails.application.routes.url_helpers.pending_invite_path(id: self.selected_user.id) unless self.selected_user.mobile_only_invite
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
        if self.user.company_admin?
          # Virtual Account -> Wallet
          credit_params[:from_account] = :virtual_account
          credit_params[:to_account] = :wallet
          actions[:credit_wallet_from_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

          if card_assigned
            # Virtual Account -> Selected User's Card
            credit_params[:from_account] = :virtual_account
            credit_params[:to_account] = :card
            actions[:credit_card_from_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

            # Selected User's card -> Virtual Account
            debit_params[:from_account] = :card
            debit_params[:to_account] = :virtual_account
            actions[:debit_card_to_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(debit_params)
          end

          # Wallet -> Virtual Account
          debit_params[:from_account] = :wallet
          debit_params[:to_account] = :virtual_account
          actions[:debit_wallet_to_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(debit_params)
        end
        if selected_user != user
          # User's Wallet -> Selected User's Wallet
          credit_params[:from_account] = :wallet
          credit_params[:to_account] = :wallet
          actions[:credit_wallet_from_wallet] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

          # Selected User's Wallet -> User's Wallet
          debit_params[:from_account] = :wallet
          debit_params[:to_account] = :wallet
          actions[:debit_wallet_to_wallet] = Rails.application.routes.url_helpers.update_balance_path(debit_params)

          if card_assigned
            # User's Card -> Selected User's Card
            credit_params[:from_account] = :card
            credit_params[:to_account] = :card
            actions[:credit_card_from_card] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

            # Selected User's Card -> User's Card
            debit_params[:from_account] = :card
            debit_params[:to_account] = :card
            actions[:debit_card_to_card] = Rails.application.routes.url_helpers.update_balance_path(debit_params)
          end
        end
      end

      if card_assigned
        # Credit actions
        # User's Wallet -> Selected User's Card
        credit_params[:from_account] = :wallet
        credit_params[:to_account] = :card
        actions[:credit_card_from_wallet] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

        # User's Card -> Selected User's Wallet
        credit_params[:from_account] = :card
        credit_params[:to_account] = :wallet
        actions[:credit_wallet_from_card] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

        # Debit actions
        # Selected User's Wallet -> User's Card
        debit_params[:from_account] = :wallet
        debit_params[:to_account] = :card
        actions[:debit_wallet_to_card] = Rails.application.routes.url_helpers.update_balance_path(debit_params)

        # Selected User's Card -> User's Wallet
        debit_params[:from_account] = :card
        debit_params[:to_account] = :wallet
        actions[:debit_card_to_wallet] = Rails.application.routes.url_helpers.update_balance_path(debit_params)


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
