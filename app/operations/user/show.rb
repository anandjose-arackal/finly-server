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
          self.card_presenter = []
          self.selected_user.cards.each do |card|
            response = (ItzCash::AccountDetails.(selected_user, card_id: card.id) rescue nil)
            if response.present? and response.success?
              self.card_presenter << response
            end
          end
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
                  :periods, :auto_submit_config, :mcc_groups, :card_periods, :cards

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
      self.cards = []
      if params[:card_presenter].present?
        params[:card_presenter].each do |card_presenter|
          actions = {}
          # Card Actions
          card = card_presenter.card
          if manager_view? or finance_view? or admin_view?
            next unless card.card_program.manager_blockable
            card_params = {}
            card_params[:view] = params[:view]
            card_params[:user_id] = selected_user.id
            card_params[:card_id] = card_presenter.card.id
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
          self.cards << {card: card, actions: actions}
        end
      end
      self.auto_submit_config = self.selected_user.auto_submit_config
      self.periods = Period.all
      self.card_periods = Period.limit(3)
      self.mcc_groups = MccGroup.all
    end

    private

    def get_managers

    end


    def load_cards

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

      actions[:transfer_options] = load_transfer_options

      actions
    end

    def load_transfer_options
      credit_actions = {initiating_accounts: [], receiving_accounts: []}
      debit_actions={receiving_accounts: [], initiating_accounts: []}

      from_user_creditable_cards = user.cards.creditable_cards
      to_user_creditable_cards = selected_user.cards.creditable_cards
      from_user_name = 'Your'
      personal_transfer = self.user == self.selected_user
      to_user_name = personal_transfer ? 'Your' : self.selected_user.name

      # From Actions
      # Virtual Account
      if user.company_admin?
        action = {type: :virtual_account, id: user.company.id, name: 'Company Credits'}
        credit_actions[:initiating_accounts] << action
        debit_actions[:initiating_accounts] << action
      end

      # Wallet
      action = {type: :wallet, id: user.wallet.id, name: "#{from_user_name}'s Finly Money"}
      credit_actions[:initiating_accounts] << action
      debit_actions[:initiating_accounts] << action

      # Cards
      if from_user_creditable_cards.present?
        from_user_creditable_cards.each do |card|

          next if (not personal_transfer and not card.card_program.manager_credit) or (personal_transfer and not card.card_program.personal_wallet_fund_transfer)

          action = {type: :card, id: card.id, name: "#{from_user_name}'s #{card.card_program.name} Card"}
          card_program = card.card_program
          if personal_transfer
            next unless card_program.personal_wallet_fund_transfer
            credit_actions[:initiating_accounts] << action
            debit_actions[:initiating_accounts] << action
          else
            next unless card_program.non_personal_fund_transfer
            credit_actions[:initiating_accounts] << action
            debit_actions[:initiating_accounts] << action
          end
        end
      end

      # To Actions
      # Wallet
      action = {type: :wallet, id: selected_user.wallet.id, name: "#{to_user_name}'s Finly Money"}
      credit_actions[:receiving_accounts] << action
      debit_actions[:receiving_accounts] << action

      # Cards
      if to_user_creditable_cards.present?
        to_user_creditable_cards.each do |card|

          action = {type: :card, id: card.id, name: "#{to_user_name}'s #{card.card_program.name} Card"}
          card_program = card.card_program
          # Verify is user is allowed to credit / debit from the card based on the card program
          if personal_transfer
            next unless card_program.personal_wallet_fund_transfer
            credit_actions[:receiving_accounts] << action
            debit_actions[:receiving_accounts] << action
          else
            if card_program.manager_credit
              credit_actions[:receiving_accounts] << action
            end
            if card_program.manager_debit
              debit_actions[:receiving_accounts] << action
            end
          end

        end
      end

      {meta: {base_url: Rails.application.routes.url_helpers.update_balance_path(receiving_user_id: selected_user.id, view: params[:view])}, credit: true, debit: true, credit_actions: credit_actions, debit_actions: debit_actions}
    end

  end
end
