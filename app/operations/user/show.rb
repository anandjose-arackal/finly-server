class User::Show < User::Base
  attr_accessor :selected_user, :balances

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
          self.balances = User::Balance.(self.user, target_user: selected_user, target_user_wallet: true,
              target_user_card: true, current_user_card: true, current_user_wallet: true, virtual_account: true,
              target_user_cash_in_hand: true, view: params[:view], request: params[:request]).balances
        end
      else
        messages[:error] = operation.messages[:error]
      end
    end
  end

  def success
    params[:selected_user] = selected_user
    params[:balances] = balances
    User::Show::Presenter.new(user, params, messages)
  end

  class User::Show::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :team_mapping, :mapping, :policies, :roles, :company_managers,
                  :company_finance_managers, :company_admins, :company_policies,
                  :actions, :team, :team_managers, :team_finance_managers, :team_policies,
                  :team_members_presenter, :selected_user, :mapping_editable, :wallet, :card,
                  :periods, :auto_submit_config, :mcc_groups, :card_periods, :cards, :balances,
                  :user_group_item_mappings, :user_groups, :unassigned_cards,
                  :user_panel_subscription

    def init
      self.selected_user = params[:selected_user]
      self.roles = {admin: self.selected_user.company_admin?, manager: self.selected_user.manager?,
                    finance_manager: self.selected_user.finance_manager?}
      self.team_mapping = self.selected_user.team_mapping
      # self.mapping = [Policy::Mappings::Show.(user, user: selected_user, policy: nil).map]
      self.policies = selected_user.policies
      self.balances = params[:balances]
      self.mapping = []
      self.policies.each do |policy|
        self.mapping << Policy::Mappings::Show.(user, user: selected_user, policy: policy).map
      end
      self.actions = load_actions(self.balances)
      self.mapping_editable = user.company_admin?
      self.wallet = self.selected_user.wallet
      self.user_panel_subscription = selected_user.user_panel_subscription
      self.cards = []
      personal = (selected_user == user)
      if balances.present?
        selected_user.cards.each do |card|
          actions = {}
          # Card Actions
          show_balance = personal ? true : card.card_program.manager_view_balance
          show_eligibility = personal ? true : card.card_program.manager_view_eligibility
          configurable_restrictions = card.card_program.spend_restrictions
          balance = show_balance ? balances[:target_user][:card][card.id][:balance] : nil
          eligibility = show_eligibility ? balances[:target_user][:card][card.id][:eligibility] : nil
          disabled_by = card.disabled_by_role.name rescue nil
          active = card.active
          name = "#{card.card_program.name} Card"
          # ending_number = card.ending_number
          proxy = card.proxy
          id = card.id

          if not personal_view? and card.card_program.manager_blockable
            card_params = {}
            card_params[:view] = params[:view]
            card_params[:user_id] = selected_user.id
            card_params[:card_id] = id
            card_params[:action_type] = nil
            if card.active
              card_params[:status_type] = User::PrepaidCard::Base::STATUS[:block]
              actions[:deactivate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
            else
              card_params[:status_type] = User::PrepaidCard::Base::STATUS[:unblock]
              actions[:activate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
            end
          elsif personal
            if card.active
              card_params = {status_type: User::PrepaidCard::Base::STATUS[:block], user_id: selected_user.id}
              actions[:deactivate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
            else
              if card.disabled_by_role_id == UserRole.id_for(:employee) or user.company_admin?
                card_params = {status_type: User::PrepaidCard::Base::STATUS[:unblock], user_id: selected_user.id}
                actions[:activate_card] = Rails.application.routes.url_helpers.update_card_status_path(card_params)
              end
            end
          end
          self.cards << {card: {show_balance: show_balance,
                                show_eligibility: show_eligibility,
                                # ending_number: ending_number,
                                proxy: proxy,
                                configurable_restrictions: configurable_restrictions,
                                balance: balance,
                                eligibility: eligibility,
                                disabled_by: disabled_by,
                                active: active, name: name, id: id},
                         actions: actions,
                         card_restriction: card.card_restriction}
        end
      end
      self.auto_submit_config = self.selected_user.auto_submit_config
      self.periods = Period.all
      self.card_periods = Period.limit(3)
      self.mcc_groups = MccGroup.all
      self.user_groups = selected_user.company.user_groups
      self.user_group_item_mappings = selected_user.user_group_item_mappings
      self.unassigned_cards = user.company.cards&.unassigned
    end

    private

    def get_managers

    end


    def load_cards

    end

    def load_actions(balances)
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

      actions[:transfer_options] = load_transfer_options(balances)

      # if viewing user is an admin and the user doesn't have cards, then a card can be assigned by the admin
      if user.company_admin? && user.company.cards&.unassigned&.present? && selected_user.cards&.expense_cards.empty?
        actions[:assign_card] = true
      else
        actions[:assign_card] = false
      end

      # adding actions for updating the panel subscriptions for the selected user
      if user.company_admin?
        actions[:update_subscriptions] = Rails.application.routes.url_helpers.user_path(id: self.selected_user.id)
      end

      actions
    end

    def load_transfer_options(balances)
      credit_actions = {initiating_accounts: [], receiving_accounts: []}
      debit_actions={receiving_accounts: [], initiating_accounts: []}

      from_user_transferable_cards = user.cards.with_non_personal_fund_transfer
      to_user_creditable_cards = selected_user.cards.creditable_cards
      from_user_name = 'Your'
      personal_transfer = self.user == self.selected_user
      to_user_name = personal_transfer ? 'Your' : "#{self.selected_user.name}'s "

      # From Actions
      # Virtual Account
      if user.company_admin?
        balance = balances[:virtual_account][:balance] rescue nil
        action = {type: :virtual_account, id: user.company.id, name: 'Company Credits', balance: balance, active: true}
        credit_actions[:initiating_accounts] << action
        debit_actions[:initiating_accounts] << action
      end

      # WalletWallet
      balance = balances[:current_user][:wallet][:balance] rescue nil
      action = {type: :wallet, id: user.wallet.id, name: "#{from_user_name} Finly Money", balance: balance, active: true}
      credit_actions[:initiating_accounts] << action
      debit_actions[:initiating_accounts] << action

      # Cards
      if from_user_transferable_cards.present?
        from_user_transferable_cards.each do |card|
          next if (not personal_transfer and not card.card_program.non_personal_fund_transfer) or (personal_transfer and not card.card_program.personal_wallet_fund_transfer)

          balance = balances[:current_user][:card][card.id][:balance] rescue nil
          eligibility = balances[:current_user][:card][card.id][:balance] rescue nil
          action = {type: :card, id: card.id, name: "#{from_user_name} #{card.card_program.name} Card",
                    balance: balance, eligibility: eligibility,
                    show_balance: true, show_eligbility: true, active: card.active}

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
      balance = balances[:target_user][:wallet][:balance] rescue nil
      action = {type: :wallet, id: selected_user.wallet.id, name: "#{to_user_name} Finly Money", balance: balance, active: true}
      credit_actions[:receiving_accounts] << action
      debit_actions[:receiving_accounts] << action

      # Cards
      if to_user_creditable_cards.present?
        to_user_creditable_cards.each do |card|
          show_balance = (personal_transfer or card.card_program.manager_view_balance)
          show_eligibility = (personal_transfer or card.card_program.manager_view_eligibility)
          balance = balances[:target_user][:card][card.id][:balance] rescue nil
          eligibility = balances[:target_user][:card][card.id][:eligibility] rescue nil

          action = {type: :card, id: card.id, name: "#{to_user_name} #{card.card_program.name} Card",
                    balance: balance, eligibility: eligibility, show_balance: show_balance,
                    show_eligibility: show_eligibility, active: card.active}

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
