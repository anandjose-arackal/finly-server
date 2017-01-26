class Settlement::Summary < Settlement::Base
  attr_accessor :selected_user, :actions, :balances

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
  end

  def init
    load_selected_user
    return if has_errors?
    load_actions
    load_balances
  end

  def success
    params[:selected_user] = selected_user
    params[:actions] = actions
    params[:balances] = balances
    Settlement::Summary::Presenter.new(user, params, messages)
  end

  class Settlement::Summary::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :selected_user, :actions, :balances

    def init
      self.selected_user = params[:selected_user]
      self.balances = params[:balances]
      self.actions = params[:actions]
    end

  end

  private
  def load_selected_user
    if personal_view?
      self.selected_user = self.user
      return
    end
    user_op = Settlement::Index.new(user, params)
    user_result = user_op.run
    unless user_op.success?
      add_message :error, user_op.messages[:error]
      return
    end
    user_id = (params[:id] or params[:user_id])
    self.selected_user = user_result.users.with_id(user_id).first rescue nil
    if self.selected_user.blank?
      add_message :error, 'User not found'
    end
  end

  def load_balances
    self.balances = User::Balance.(user, target_user: selected_user, target_user_all: true).balances
  end

  def load_actions
    return unless admin_view? or finance_view?
    return if self.selected_user.id == user.id and not admin_view?
    self.actions = {}
    self.actions[:credit_reimbursement] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:reimbursement).to_s)
    # self.actions[:credit_settle] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:settlement))
    # self.actions[:debit_settle] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:settlement))
    self.actions[:debit_cash_advance] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:debt_clearance))
    self.actions[:credit_cash_advance] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:advance))
    self.actions[:credit_money_request] = Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:advance))

    is_card_assigned = self.selected_user.cards.present?
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

        if is_card_assigned
          # Virtual Account -> Card
          credit_params[:from_account] = :virtual_account
          credit_params[:to_account] = :card
          actions[:credit_card_from_virtual_account] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

          # Card -> Virtual account
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

        if is_card_assigned
          # User's Card -> Selected User's Card
          credit_params[:from_account] = :card
          credit_params[:to_account] = :card
          actions[:credit_card_from_card] = Rails.application.routes.url_helpers.update_balance_path(credit_params)

          # Selected User's Card -> User's Card
          debit_params[:from_account] = :card
          debit_params[:to_account] = :card
          actions[:debit_card_to_card] = Rails.application.routes.url_helpers.update_balance_path(credit_params)
        end

      end
    end

    if is_card_assigned
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
      actions[:debit_card_to_wallet] = Rails.application.routes.url_helpers.update_balance_path(credit_params)
    end

    if is_card_assigned
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
  end
end