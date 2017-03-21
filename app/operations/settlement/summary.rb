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
    load_transfer_options
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
    personal = user == selected_user
    result = User::Balance.(user, target_user: selected_user, target_user_all: true).balances
    self.balances = {}

    self.balances[:wallet] = {balance: result[:target_user][:wallet][:balance], name: 'Finly Money'}
    if result[:target_user][:card].present?
      self.balances[:cards] = []
      result[:target_user][:card].each do |id, item|
        card = Card.with_id(id).first
        creditable = ((personal and card.card_program.personal_wallet_fund_transfer) or (!personal and card.card_program.manager_credit))
        debitable = ((personal and card.card_program.personal_wallet_fund_transfer) or (!personal and card.card_program.manager_debit))
        self.balances[:cards] << {id: item[:id], program_name: item[:name], show_balance: item[:show_balance], balance: item[:balance], show_eligibility: item[:show_eligibility],
                                 eligibility: item[:eligibility], creditable: creditable, debitable: debitable, enabled: card.active}
      end
    end
    self.balances[:cash_on_hand] = {balance: result[:target_user][:cash_on_hand][:balance], name: 'Cash on Hand'}
    self.balances[:pending_money_requests] = {balance: result[:target_user][:pending_money_requests][:balance], count: result[:target_user][:pending_money_requests][:count]}
    self.balances[:pending_reports] = {balance: result[:target_user][:pending_reports][:balance], count: result[:target_user][:pending_reports][:count]}

    # result[:target_user].each do |item|
    #   next if item[:type].blank?
    #   case item[:type]
    #     when :wallet
    #       self.balances[:wallet] = {balance: item[:balance]}
    #     when :card
    #       self.balances[:card] = [] if self.balances[:card].blank?
    #       card = Card.with_id(item[:id]).first
    #       creditable = ((personal and card.card_program.personal_wallet_fund_transfer) or (!personal and card.card_program.manager_credit))
    #       debitable = ((personal and card.card_program.personal_wallet_fund_transfer) or (!personal and card.card_program.manager_debit))
    #       self.balances[:card] << {id: item[:id], program_name: item[:name], show_balance: item[:show_balance], balance: item[:balance], show_eligibility: item[:show_eligibility],
    #                                eligibility: item[:eligibility], creditable: creditable, debitable: debitable, enabled: card.active}
    #     when :cash_on_hand
    #       self.balances[:cash_on_hand] = {balance: item[:balance]}
    #     when :pending_money_requests
    #       self.balances[:pending_money_requests] = {balance: item[:balance], count: item[:count]}
    #     when :pending_reports
    #       self.balances[:pending_reports] = {balance: item[:balance], count: item[:count]}
    #   end
    # end
  end

  def load_transfer_options
    credit_actions = {initiating_accounts: [], receiving_accounts: []}
    debit_actions={initiating_accounts: [], receiving_accounts: []}

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

    self.actions = {meta: {base_url: Rails.application.routes.url_helpers.update_balance_path(to_user_id: selected_user.id, view: params[:view])}, credit: true, debit: true, credit_actions: credit_actions, debit_actions: debit_actions}
  end

end