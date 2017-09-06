class User::Balances::Show < User::Base

  attr_accessor :balances, :current_app, :selected_user

  def init
    self.current_app = RequestStore.store[:current_app].to_s
    self.balances = {}
    if admin_panel?
      id = params[:id] || params[:user_id]
      self.selected_user = User.find_by(id: id)
    else
      self.selected_user = user
    end
  end

  def validate

  end

  def process
    case current_app
      when 'em'
        # Adding expense management balances in this section if it's enabled for that user
        if selected_user.company.expense_management_enabled? && selected_user.expense_management_enabled?
          if selected_user.admin?
            company_adapter = retrieve_adapter(user.company.itz_cash_company_account)
            self.balances[:card_balance_credits] = company_adapter.balance
          end
          wallet_adapter = retrieve_adapter(user.wallet)
          self.balances[:finly_money_card_transfer_pocket] = wallet_adapter.balance
          self.balances[:expense_management] = true
        else
          self.balances[:expense_management] = false
        end

        if selected_user.cards.present?
          self.balances[:cards] = []
          selected_user.cards.each do |card|
            card_adapter = retrieve_adapter(card)
            self.balances[:cards] << {
                type: card.card_program.name,
                balance: card_adapter.balance,
                id: card.id
            }
          end
        end

        # adding vendor payment balances in this section if it is enabled for that selected_user
        if selected_user.company.vendor_payments_enabled? && selected_user.vendor_payments_enabled?
          if selected_user.vendor_payments_admin?
            company_adapter = retrieve_adapter(user.company.yes_bank_company_account)
            self.balances[:bank_transfer_credits] = company_adapter.balance
          end
          wallet_adapter = retrieve_adapter(user.bank_wallet)
          self.balances[:finly_money_bank_transfer_pocket] = wallet_adapter.balance
          self.balances[:vendor_payments] = true
        else
          self.balances[:vendor_payments] = false
        end

      when 'vp'
        if selected_user.company.vendor_payments_enabled? && selected_user.vendor_payments_enabled?
          if selected_user.vendor_payments_admin?
            company_adapter = retrieve_adapter(user.company.yes_bank_company_account)
            self.balances[:bank_transfer_credits] = company_adapter.balance
          end
          wallet_adapter = retrieve_adapter(user.bank_wallet)
          self.balances[:finly_money_bank_transfer_pocket] = wallet_adapter.balance
          self.balances[:vendor_payments] = true
        else
          self.balances[:vendor_payments] = false
        end

      when 'ft'

        # Adding expense management balances in this section if it's enabled for that user
        if selected_user.company.cards_enabled && selected_user.expense_management_enabled?
          if selected_user.admin?
            company_adapter = retrieve_adapter(user.company.itz_cash_company_account)
            self.balances[:card_balance_credits] = company_adapter.balance
          end
          wallet_adapter = retrieve_adapter(user.wallet)
          self.balances[:finly_money_card_transfer_pocket] = wallet_adapter.balance
          self.balances[:disburse] = true
        else
          self.balances[:disburse] = false
        end
      else
        # do nothing?
    end
  end

  def post_process

  end

  def success
    params[:balances] = self.balances
    User::Balances::Show::BalancePresenter.new(user, params, messages)
  end

  class User::Balances::Show::BalancePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :balances

    def init
      self.balances = params[:balances]
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

end