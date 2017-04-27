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
    result = User::Balance.(user, target_user: selected_user, current_user_all: true, target_user_all: true, virtual_account: true).balances

    load_transfer_options(result)

    self.balances = {}
    self.balances[:wallet] = {balance: result[:target_user][:wallet][:balance], name: 'Finly Money', id: selected_user.wallet.id}
    if result[:target_user][:card].present?
      self.balances[:cards] = []
      result[:target_user][:card].each do |id, item|
        card = Card.with_id(id).first
        creditable = ((personal and card.card_program.personal_wallet_fund_transfer) or (!personal and card.card_program.manager_credit))
        debitable = ((personal and card.card_program.personal_wallet_fund_transfer) or (!personal and card.card_program.manager_debit))
        disabler = nil
        if not card.active and card.disabled_by_role_id.present? and card.disabled_by_user_id.present?
          disabler = {role: {id: card.disabled_by_role_id, name: card.disabled_by_role.name},
                      user: {id: card.disabled_by_user_id,
                             name: card.disabled_by_user.name}}
        end
        self.balances[:cards] << {id: item[:id], name: "#{item[:name]} Card",
                                  show_balance: item[:show_balance], balance: item[:balance],
                                  show_eligibility: item[:show_eligibility],
                                  eligibility: item[:eligibility], creditable: creditable,
                                  debitable: debitable, active: card.active, disabler: disabler}
      end
    end

    self.balances[:cash_on_hand] = {balance: result[:target_user][:cash_on_hand][:balance], name: 'Cash on Hand',
                                    meta: {credit: {base_url: Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:add_cash_on_hand))},
                                           debit: {base_url: Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:deduct_cash_on_hand))}}}
    self.balances[:pending_money_requests] = {balance: result[:target_user][:pending_money_requests][:balance], count: result[:target_user][:pending_money_requests][:count],
                                              meta: {base_url: Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:add_cash_on_hand))}}


    reimbursement = load_reimbursement(personal, result)

    self.balances[:pending_reports] = {balance: result[:target_user][:pending_reports][:balance],
                                       count: result[:target_user][:pending_reports][:count],
                                       reimbursement: reimbursement,
                                       meta: {base_url: Rails.application.routes.url_helpers.settlements_path(id: selected_user.id, payment_type: PaymentType.id_for(:reimbursement).to_s)}}

  end

  def load_reimbursement(personal, balances)
    to_user_reimbursable_card = selected_user.cards.reimbursable_cards.first rescue nil
    to_user_reimbursement_bank_account = selected_user.itz_cash_dmt_sender&.beneficiaries.active.reimbursement_accounts.default
    reimbursement = {associated_reimbursement_card: (!!to_user_reimbursable_card&.active),
                     card: {},
                     associated_reimbursement_bank_account: (),
                     initiating_accounts: []
                    }

    if to_user_reimbursable_card
      name = personal ? 'Your Reimbursement card' : "#{selected_user.name}'s Reimbursement Card"
      eligibility = balances[:target_user][:card][to_user_reimbursable_card.id][:eligibility]
      reimbursement[:card] = {id: to_user_reimbursable_card.id, name: name, eligibility: eligibility}
    end
    reimbursement[:initiating_accounts] = self.actions[:credit_actions][:initiating_accounts]
    reimbursement
  end

  def load_transfer_options(balances)
    credit_actions = {initiating_accounts: [], receiving_accounts: []}
    debit_actions={initiating_accounts: [], receiving_accounts: []}

    from_user_transferable_cards =  user.cards.with_non_personal_fund_transfer
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

    # Wallet
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
        disabler = nil
        disabler_name = card.disabled_by_user.name rescue nil
        disabled_by_role = card.disabled_by_role_id == UserRole.id_for(:employee) ? "" : (card.disabled_by_role.name rescue nil)
        unless card.active
          disabler = {role: {id: card.disabled_by_role_id, name: disabled_by_role}, user: {id: card.disabled_by_user_id, name: disabler_name}}
        end

        action = {type: :card, id: card.id,
                  name: "#{from_user_name} #{card.card_program.name} Card",
                  balance: balance, eligibility: eligibility, show_balance: true,
                  show_eligibility: true, active: card.active, disabler: disabler}


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
        disabler = nil
        if not card.active and card.disabled_by_role_id.present? and card.disabled_by_user_id.present?
          disabler_name = card.disabled_by_user.name rescue nil
          disabled_by_role = card.disabled_by_role_id == UserRole.id_for(:employee) ? "" : (card.disabled_by_role.name rescue nil)
          disabler = {role: {id: card.disabled_by_role_id, name: disabled_by_role},
                      user: {id: card.disabled_by_user_id,
                             name: disabler_name}}
        end

        action = {type: :card, id: card.id, name: "#{to_user_name} #{card.card_program.name} Card",
                  balance: balance, eligibility: eligibility, show_balance: show_balance,
                  show_eligibility: show_eligibility, active: card.active, disabler: disabler}

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

    self.actions = {meta: {base_url: Rails.application.routes.url_helpers.update_balance_path(receiving_user_id: selected_user.id, view: params[:view])},
                    credit: true, debit: true, credit_actions: credit_actions, debit_actions: debit_actions}
  end

end