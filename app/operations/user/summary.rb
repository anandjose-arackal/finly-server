class User::Summary < User::Base
  attr_accessor :selected_user, :cards, :summary

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
  end

  def init
    id = (params[:id] or params[:user_id])
    if personal_view? or id == user.id
      self.selected_user = user
    else
      operation = User::Team::Index.new(user, params)
      result = operation.run
      if operation.success?
        self.selected_user = result.with_id(id).first rescue nil
      else
        messages[:error] = operation.messages[:error]
      end
    end
  end

  def validate
    if selected_user.blank?
      raise_unauthorized_exception
    end
  end

  def process
    self.summary = {}

    balances = User::Balance.(self.user, target_user: selected_user, target_user_wallet: true,
        target_user_card: true, current_user_card: true, current_user_wallet: true, virtual_account: true,
        target_user_cash_in_hand: true, view: params[:view]).balances

    summary[:cards] = []
    if self.selected_user.cards.present?
      self.selected_user.cards.each do |card|
        item = {}
        item[:id] = card.id
        item[:card_program] = {name: card.card_program.name, id: card.card_program.id}
        item[:active] = card.active
        unless card.active
          disabled_by_role_name = card.disabled_by_role.name rescue nil
          disabled_by_user_name = card.disabled_by_user.name rescue nil
          item[:disabler] = {role: {id: card.disabled_by_role_id, name: disabled_by_role_name}, user: {id: card.disabled_by_user_id, name: disabled_by_user_name}}
        end
        item[:balance] = balances[:target_user][:card][card.id][:balance] rescue nil
        item[:available_eligibility] = balances[:target_user][:card][card.id][:eligibility] rescue nil
        item[:ending_number] = card.ending_number
        item[:actions] = {}
        item[:actions][:unblockable] = card.unblockable? # determining of the user can unblock the card at this stage
        item[:actions][:meta] = {}
        item[:actions][:meta][:base_url] = Rails.application.routes.url_helpers.update_card_status_path
        summary[:cards] << item
      end
    end

    summary[:wallet] = {id: selected_user.wallet.id, balance: balances[:target_user][:wallet][:balance], name: 'Finly Money'}

    summary[:virtual_account] = balances[:virtual_account] if selected_user.company_admin?

    summary[:cash_on_hand] = {name: 'Cash on Hand', balance: balances[:target_user][:cash_on_hand][:balance]}

    summary[:actions] = load_actions balances

    summary[:current_user_name] = user.name
    
    summary[:personal] = {}
    summary[:personal][:unreported_expenses] = selected_user.expenses.unreported.count
    summary[:personal][:unsubmitted_reports] = selected_user.reports.open.count
    summary[:personal][:unsubmitted_money_requests] = selected_user.money_requests.open.count

    if selected_user.manager?
      summary[:manager] = {}
      summary[:manager][:pending_reports] = selected_user.manager_reports.with_controlling_user_id(selected_user.id).count rescue 0
      summary[:manager][:pending_money_requests] = selected_user.manager_money_requests.with_controlling_user_id(selected_user.id).count rescue 0
    end

    if selected_user.finance_manager?
      summary[:finance_manager] = {}
      summary[:finance_manager][:pending_reports] = selected_user.finance_reports.with_controlling_user_id(selected_user.id).count rescue 0
      summary[:finance_manager][:pending_money_requests] = selected_user.finance_money_requests.with_controlling_user_id(selected_user.id).count rescue 0
    end
  end

  def success
    User::Summary::Presenter.new(self.user, summary, messages)
  end

  class User::Summary::Presenter < BaseOperation::BasePresenter::SuccessPresenter

  end

  protected
  def load_actions(balances)
    credit_actions = {initiating_accounts: [], receiving_accounts: []}
    debit_actions={receiving_accounts: [], initiating_accounts: []}

    initiating_user_creditable_cards = user.cards.creditable_cards
    receiving_user_creditable_cards = selected_user.cards.creditable_cards
    initiating_user_name = 'Your'
    personal_transfer = self.user == self.selected_user
    receiving_user_name = personal_transfer ? 'Your' : self.selected_user.name

    # From Actions
    # Virtual Account
    if user.company_admin?
      balance = balances[:virtual_account][:balance] rescue nil
      action = {type: :virtual_account, id: user.company.id, name: 'Company Credits', balance: balance, active: true}
      credit_actions[:initiating_accounts] << action
      debit_actions[:initiating_accounts] << action
    end

    # Wallet
    balance = balances[:current_user][:wallet][:balance] rescue nil
    action = {type: :wallet, id: user.wallet.id, name: "#{initiating_user_name}'s Finly Money",
              balance: balance, active: true}
    credit_actions[:initiating_accounts] << action
    debit_actions[:initiating_accounts] << action

    # Cards
    if initiating_user_creditable_cards.present?
      initiating_user_creditable_cards.each do |card|
        next if (not personal_transfer and not card.card_program.manager_credit) or (personal_transfer and not card.card_program.personal_wallet_fund_transfer)

        balance = balances[:current_user][:card][card.id][:balance] rescue nil
        eligibility = balances[:current_user][:card][card.id][:balance] rescue nil
        action = {type: :card, id: card.id, name: "#{initiating_user_name}'s #{card.card_program.name} Card",
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
    action = {type: :wallet, id: selected_user.wallet.id, name: "#{receiving_user_name}'s Finly Money",
              balance: balance, active: true}
    credit_actions[:receiving_accounts] << action
    debit_actions[:receiving_accounts] << action

    # Cards
    if receiving_user_creditable_cards.present?
      receiving_user_creditable_cards.each do |card|
        show_balance = (personal_transfer or card.card_program.manager_view_balance)
        show_eligibility = (personal_transfer or card.card_program.manager_view_eligibility)
        balance = balances[:target_user][:card][card.id][:balance] rescue nil
        eligibility = balances[:target_user][:card][card.id][:balance] rescue nil

        action = {type: :card, id: card.id, name: "#{receiving_user_name}'s #{card.card_program.name} Card",
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