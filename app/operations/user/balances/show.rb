class User::Balances::Show < User::Base

  attr_accessor :balances, :current_app, :selected_user, :actions,
                :wallet_info, :company_credits_info, :card_info, :cash_on_hand_info

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
    self.balances = {company_credits: [], finly_money: [], cards: [], cash_on_hand: []}
    retrieve_balances
  end

  def validate

  end

  def process
    case current_app
      when 'em'
        # Adding expense management balances in this section if it's enabled for that user
        if selected_user.company.expense_management_enabled? && selected_user.expense_management_enabled?
          set_itz_cash_balances
        end
        if selected_user.cards.present?
          set_card_balances
        end
        # adding vendor payment balances in this section if it is enabled for that selected_user
        if selected_user.company.vendor_payments_enabled? && selected_user.vendor_payments_enabled?
          set_yes_bank_balances
        end
      when 'vp'
        if selected_user.company.vendor_payments_enabled? && selected_user.vendor_payments_enabled?
          set_yes_bank_balances
        end
      when 'ft'
        # Adding expense management balances in this section if it's enabled for that user
        if selected_user.company.cards_enabled && selected_user.expense_management_enabled?
          set_itz_cash_balances
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
    User::Balances::Show::BalancePresenter.new(user, params, messages)
  end

  class User::Balances::Show::BalancePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balances, :selected_user, :show_company_credits, :actions

    def init
      self.balances = params[:balances]
      self.selected_user = params[:selected_user]
      self.actions = params[:actions]
      self.show_company_credits = (self.selected_user.admin?) ? true : false
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
      else # i.e. the transaction has happened outside Finly
        return AccountManager::OutsideFinly::OutsideFinlyAdapter.new
    end
  end

  def retrieve_balances
    itz_cash_company_adapter = retrieve_adapter selected_user.company.itz_cash_company_account
    yes_bank_company_adapter = retrieve_adapter selected_user.company.yes_bank_company_account
    wallet_adapter = retrieve_adapter user.wallet
    bank_wallet_adapter = retrieve_adapter user.bank_wallet
    cash_on_hand_adapter = retrieve_adapter user.cash_on_hand

    selected_user.cards.each do |card|
      card_adapter = retrieve_adapter(card)
      self.card_info = {
         card.id => {
             balance: card_adapter.balance,
             eligibility: card_adapter.credit_eligibility
         }
      }
    end
    self.company_credits_info = {
        yes_bank: {
            balance: yes_bank_company_adapter.balance
        },
        itz_cash: {
            balance: itz_cash_company_adapter.balance
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
    self.cash_on_hand_info = {
        itz_cash: {
            balance: cash_on_hand_adapter.balance
        }
    }
  end

  def set_itz_cash_balances
    if selected_user.admin?
      self.balances[:company_credits] << {
          name: "Card Transfer Credits",
          balance: self.company_credits_info[:itz_cash][:balance]
      }
    end
    # adding finly money
    self.balances[:finly_money] << {
        name: "Finly Money (Card Transfer Pocket",
        balance: self.wallet_info[:itz_cash][:balance]
    }
    # adding cash on hand
    self.balances[:cash_on_hand] << {
        name: "Cash On Hand",
        balance: self.wallet_info[:itz_cash][:balance]
    }
  end

  def set_yes_bank_balances
    if selected_user.vendor_payments_admin?
      self.balances[:company_credits] << {
          name: "Bank Transfer Credits",
          balance: self.company_credits_info[:yes_bank][:balance]
      }
    end
    self.balances[:finly_money] << {
        name: "Finly Money (Bank Transfer Credits)",
        balance: self.wallet_info[:yes_bank][:balance]
    }
  end

  def set_card_balances
    if selected_user.cards.present?
      selected_user.cards.each do |card|
        balance = (card.manager_view_balance) ? self.card_info[card.id][:balance] : nil
        self.balances[:cards] << {
            name: "#{selected_user.name}'s #{card.card_program.name.humanize} card",
            balance: balance,
            eligibility: self.card_info[card.id][:eligibility]
        }
      end
    end
  end

  def set_actions
    # check if the user is enabled for expense management first
    credit_actions = {initiating_accounts: [], receiving_accounts: []}
    debit_actions = {initiating_accounts: [], receiving_accounts: []}
    if user.expense_management_enabled?
      # first add wallet balance
      credit_actions[:initiating_accounts] << {
          type: "wallet",
          id: selected_user.wallet.id,
          name: "#{selected_user.name}'s Finly Money (Card Transfer Pocket)",
          balance: self.wallet_info[:itz_cash][:balance]
      }
      credit_actions[:receiving_accounts] << {
          type: "wallet",
          id: selected_user.wallet.id,
          name: "#{selected_user.name}'s Finly Money (Card Transfer Pocket)",
          balance: self.wallet_info[:itz_cash][:balance]
      }
      debit_actions[:initiating_accounts] << {
          type: "wallet",
          id: selected_user.wallet.id,
          name: "#{selected_user.name}'s Finly Money (Card Transfer Pocket)",
          balance: self.wallet_info[:itz_cash][:balance]
      }
      debit_actions[:receiving_accounts] << {
          type: "wallet",
          id: selected_user.wallet.id,
          name: "#{selected_user.name}'s Finly Money (Card Transfer Pocket)",
          balance: self.wallet_info[:itz_cash][:balance]
      }

      # now add card balances
      if selected_user.cards.expense_cards.present?
        selected_user.cards.expense_cards.each do |card|
          credit_actions[:initiating_accounts] << {
              type: "card",
              id: card.id,
              name: "#{selected_user.name}'s Expense Card",
              balance: self.card_info[card.id][:balance]
          }
          debit_actions[:initiating_accounts] << {
              type: "card",
              id: card.id,
              name: "#{selected_user.name}'s Expense Card",
              balance: self.card_info[card.id][:balance]
          }
          credit_actions[:receiving_accounts] << {
              type: "card",
              id: card.id,
              name: "#{selected_user.name}'s Expense Card",
              balance: self.card_info[card.id][:balance]
          }
          debit_actions[:receiving_accounts] << {
              type: "card",
              id: card.id,
              name: "#{selected_user.name}'s Expense Card",
              balance: self.card_info[card.id][:balance]
          }
        end
      end

      # now based on whether the user is an admin or not, add company credits
      if selected_user.admin?
        credit_actions[:initiating_accounts] << {
            type: "company",
            id: selected_user.company.itz_cash_company_account.id,
            name: "Company Credits (Card Transfer Pocket)",
            balance: self.company_credits_info[:itz_cash][:balance]
        }
        debit_actions[:initiating_accounts] << {
            type: "company",
            id: selected_user.company.itz_cash_company_account.id,
            name: "Company Credits (Card Transfer Pocket)",
            balance: self.company_credits_info[:itz_cash][:balance]
        }
        credit_actions[:receiving_accounts] << {
            type: "company",
            id: selected_user.company.itz_cash_company_account.id,
            name: "Company Credits (Card Transfer Pocket)",
            balance: self.company_credits_info[:itz_cash][:balance]
        }
        debit_actions[:receiving_accounts] << {
            type: "company",
            id: selected_user.company.itz_cash_company_account.id,
            name: "Company Credits (Card Transfer Pocket)",
            balance: self.company_credits_info[:itz_cash][:balance]
        }
      end
    end
    self.actions = {
        credit_actions: credit_actions,
        debit_actions: debit_actions
    }
  end

end