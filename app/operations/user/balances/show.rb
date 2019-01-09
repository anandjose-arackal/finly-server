class User::Balances::Show < User::Base

  attr_accessor :balances, :current_app, :selected_user, :actions,
                :wallet_info, :company_credits_info, :card_info, :user_pockets_info

  # using *_info is being used to store all balances and eligibility for this particular user
  # so that the APIs are not called repeatedly in multiple places

  def init
    self.current_app = RequestStore.store[:current_app].to_s
    self.balances = {}
    if admin_panel?
      id = params[:id] || params[:user_id]
      self.selected_user = User.find_by(id: id)
    else
      self.selected_user = user
    end
    self.balances = {company_credits: [], finly_money: [], cards: [], user_pockets: []}
    retrieve_balances
  end

  def validate

  end

  def process
    case current_app
      when 'em'
        # Adding expense management balances in this section if it's enabled for that user
        if selected_user.company.d_code_enabled? && selected_user.expense_management_enabled?
          set_itz_cash_balances
        end
        if selected_user.cards.present?
          set_card_balances
        end
        # adding vendor payment balances in this section if it is enabled for that selected_user
        if (selected_user.company.vendor_payments_enabled? && selected_user.vendor_payments_enabled?) || selected_user.company.bank_reimbursement_enabled?
          set_yes_bank_balances
        end
        # showing user pocket balances based on whether they have expense management enabled
        if selected_user.company.expense_management_enabled? && selected_user.expense_management_enabled?
          set_pocket_balances
        end
      when 'vp'
        if selected_user.company.vendor_payments_enabled? && selected_user.vendor_payments_enabled?
          set_yes_bank_balances
        end
      when 'ft'
        # Adding expense management balances in this section if it's enabled for that user
        if selected_user.company.cards_enabled? && selected_user.disburse_enabled?
          set_itz_cash_balances
        end
        if selected_user.cards.present?
          set_card_balances
        end
      when 'fc'
        if selected_user.company.invoicing_system_enabled? && selected_user.invoicing_system_enabled?
          set_collect_balances
        end
      else
        # do nothing?
    end
    # setting actions for this particular
    set_actions
  end

  def post_process

  end

  def success
    params[:balances] = self.balances
    params[:actions] = self.actions
    params[:selected_user] = self.selected_user
    params[:current_app] = self.current_app
    User::Balances::Show::BalancePresenter.new(user, params, messages)
  end

  class User::Balances::Show::BalancePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balances, :selected_user, :show_company_credits, :actions, :current_app

    def init
      self.balances = params[:balances]
      self.selected_user = params[:selected_user]
      self.actions = params[:actions]
      self.current_app = params[:current_app]
      self.show_company_credits = (self.selected_user.admin?(current_app)) ? true : false
    end
  end

  private

  def retrieve_adapter(account)
    acc_type = account&.class&.to_s
    case acc_type
      when 'Card'
        return AccountManager::Cards::CardAdapter.new(account)
      when 'UserWallet'
        return AccountManager::Wallet::WalletAdapter.new(account)
      when 'YesBankCompanyAccount'
        return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(account)
      when 'CashOnHand'
        return AccountManager::CashOnHand::CashOnHandAdapter.new(account)
      when 'ItzCashCompanyAccount'
        return AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(account)
      when 'VendorPaymentWallet'
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(account)
      when 'UserPocket'
        case account.user_pocket_type_id
          when UserPocketType.id_for(:cash)
            return AccountManager::CashPockets::CashPocketsAdapter.new(account)
          when UserPocketType.id_for(:credit_card)
            return AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(account)
          when UserPocketType.id_for(:card_transfer)
            return AccountManager::CardTransferPockets::CardTransferPocketsAdapter.new(account)
          when UserPocketType.id_for(:bank_transfer)
            return AccountManager::BankTransferPockets::BankTransferPocketsAdapter.new(account)
          when UserPocketType.id_for(:reimbursement)
            return AccountManager::ReimbursementPockets::ReimbursementPocketsAdapter.new(account)
          when UserPocketType.id_for(:paid_by_company)
            return AccountManager::PaidByCompanyPockets::PaidByCompanyPocketsAdapter.new(account)
          else
            # do nothing?
        end
      else # i.e. the transaction has happened outside Finly
        return AccountManager::OutsideFinly::OutsideFinlyAdapter.new
    end
  end

  def retrieve_balances
    itz_cash_company_adapter = retrieve_adapter selected_user.company.itz_cash_company_account
    yes_bank_company_adapter = retrieve_adapter selected_user.company.yes_bank_company_account
    wallet_adapter = retrieve_adapter user.wallet
    bank_wallet_adapter = retrieve_adapter user.bank_wallet

    self.card_info = {}
    selected_user.cards.each do |card|
      card_adapter = retrieve_adapter(card)
      self.card_info[card.id] =
         {
             balance: card_adapter.balance,
             eligibility: card_adapter.credit_eligibility
         }
    end
    comp_balance = itz_cash_company_adapter.balance
    unless comp_balance
      comp_balance = "Temporarily unavailable"
    end
    self.company_credits_info = {
        yes_bank: {
            balance: yes_bank_company_adapter.balance
        },
        itz_cash: {
            balance: comp_balance
        }
    }
    self.wallet_info = {
        yes_bank: {
            balance: bank_wallet_adapter.balance
        },
        itz_cash: {
            balance: wallet_adapter.balance
        }
    }
    self.selected_user.user_pockets.each do |pocket|
      pocket_adapter = retrieve_adapter(pocket)
      self.user_pockets_info = {} unless self.user_pockets_info.is_a?(Hash)
      self.user_pockets_info[pocket.id] = pocket_adapter.balance(display_balance: true)
    end
  end

  def set_itz_cash_balances
    if selected_user.admin?
      self.balances[:company_credits] = [] if self.balances[:company_credits].blank?
      self.balances[:company_credits] << {
          name: "Card Transfer Credits",
          type: "card",
          balance: self.company_credits_info[:itz_cash][:balance]
      }
    end
    # adding finly money
    self.balances[:finly_money] = [] if self.balances[:finly_money].blank?
    self.balances[:finly_money] << {
        name: "Card Transfer Pocket",
        type: "card",
        balance: self.wallet_info[:itz_cash][:balance]
    }
  end

  def set_yes_bank_balances
    if selected_user.vendor_payments_admin? || (selected_user.company.bank_reimbursement_enabled? || selected_user.admin?)
      self.balances[:company_credits] = [] if self.balances[:company_credits].blank?
      self.balances[:company_credits] << {
          name: "Bank Transfer Credits",
          type: "bank",
          balance: self.company_credits_info[:yes_bank][:balance]
      }
    end
    self.balances[:finly_money] = [] if self.balances[:finly_money].blank?
    self.balances[:finly_money] << {
        name: "Bank Transfer Pocket",
        type: "bank",
        balance: self.wallet_info[:yes_bank][:balance]
    }
  end

  def set_collect_balances
    # if selected_user.collect_admin?
      self.balances[:company_credits] = [] if self.balances[:company_credits].blank?
      self.balances[:company_credits] << {
          name: "Finly Collect Credits",
          type: "bank",
          balance: self.company_credits_info[:yes_bank][:balance]
      }
    # end
  end

  def set_card_balances
    if selected_user.cards.present?
      selected_user.cards.each do |card|
        balance = (card.manager_view_balance) ? self.card_info[card.id][:balance] : nil
        disabler = card.disabled_by_user&.name
        disabler_role = card.disabled_by_role&.name
        self.balances[:cards] << {
            name: "#{card.card_program.name.humanize}",
            balance: balance,
            eligibility: self.card_info&.dig(card.id, :eligibility),
            active: card.active,
            disabler: disabler,
            disabler_role: disabler_role
        }
      end
    end
  end

  def set_pocket_balances
    # adding pocket balances
    self.balances[:user_pockets] = [] if self.balances[:user_pockets].blank?
    self.selected_user.user_pockets.cash_and_credit_cards.each do |pocket|
      self.balances[:user_pockets] << {
          name: pocket.name,
          type: pocket.user_pocket_type&.name&.humanize,
          balance: self.user_pockets_info[pocket.id],
          base_currency: pocket.base_currency
      }
    end
  end

  def set_actions
    # check if the user is enabled for expense management first
    credit_actions = {initiating_accounts: [], receiving_accounts: []}
    debit_actions = {initiating_accounts: [], receiving_accounts: []}
    meta = {base_url: nil}
    if expense_management? && selected_user.expense_management_enabled?
      # first add wallet balance
      wallet_action = {
          type: "wallet",
          id: selected_user.wallet.id,
          name: "#{selected_user.name}'s Finly Money (Card Transfer Pocket)",
          balance: self.wallet_info[:itz_cash][:balance],
          active: selected_user.active
      }
      credit_actions[:initiating_accounts] << wallet_action
      credit_actions[:receiving_accounts] << wallet_action
      debit_actions[:initiating_accounts] << wallet_action
      debit_actions[:receiving_accounts] << wallet_action

      # now add card balances
      if selected_user.cards.expense_cards.present?
        selected_user.cards.expense_cards.each do |card|
          disabler = card.disabled_by_user&.name
          disabler_role = card.disabled_by_role&.name
          card_action = {
              type: "card",
              id: card.id,
              name: "#{selected_user.name}'s Expense Card",
              balance: self.card_info[card.id][:balance],
              eligibility: self.card_info&.dig(card.id, :eligibility),
              active: card.active,
              disabler: disabler,
              disabler_role: disabler_role
          }
          credit_actions[:initiating_accounts] << card_action
          credit_actions[:receiving_accounts] << card_action
          debit_actions[:initiating_accounts] << card_action
          debit_actions[:receiving_accounts] << card_action
        end
      end

      # now based on whether the user is an admin or not, add company credits
      if selected_user.admin?
        company_action = {
            type: "company",
            id: selected_user.company.itz_cash_company_account.id,
            name: "Company Credits (Card Transfer Pocket)",
            balance: self.company_credits_info[:itz_cash][:balance],
            active: true
        }
        credit_actions[:initiating_accounts] << company_action
        credit_actions[:receiving_accounts] << company_action
        debit_actions[:initiating_accounts] << company_action
        debit_actions[:receiving_accounts] << company_action
      end

      # sending the base url for transferring money between accounts
      meta[:base_url] = Rails.application.routes.url_helpers.update_balance_path(receiving_user_id: selected_user.id)

    elsif vendor_payments? && selected_user.vendor_payments_enabled?
      # first add wallet balance
      wallet_action = {
          type: "wallet",
          id: selected_user.bank_wallet.id,
          name: "#{selected_user.name}'s Finly Money (Bank Transfer Pocket)",
          balance: self.wallet_info[:yes_bank][:balance],
          active: selected_user.active
      }
      credit_actions[:initiating_accounts] << wallet_action
      credit_actions[:receiving_accounts] << wallet_action
      debit_actions[:initiating_accounts] << wallet_action
      debit_actions[:receiving_accounts] << wallet_action

      # now based on whether the user is an admin or not, add company credits
      if selected_user.vendor_payments_admin?
        company_action = {
            type: "company",
            id: selected_user.company.yes_bank_company_account.id,
            name: "Company Credits (Bank Transfer Pocket)",
            balance: self.company_credits_info[:yes_bank][:balance],
            active: true
        }
        credit_actions[:initiating_accounts] << company_action
        credit_actions[:receiving_accounts] << company_action
        debit_actions[:initiating_accounts] << company_action
        debit_actions[:receiving_accounts] << company_action
      end

      # sending the base url for transferring money from company account to wallets
      meta[:base_url] = Rails.application.routes.url_helpers.bank_transfer_update_balance_path
    end
    self.actions = {
        credit_actions: credit_actions,
        debit_actions: debit_actions,
        meta: meta
    }
  end

end