# accepts a particular pair of users and returns the transfer options that are available
# between them

class BankTransfer::VendorPaymentWallet::TransferOptions < BankTransfer::VendorPaymentWallet::Base

  attr_accessor :transfer_options, :selected_user

  def authorized_user_types
    [:company_admin, :finance_manager]
  end

  def pre_validate

  end

  def init
    id = params[:id] || params[:user_id]
    # todo - change this to extract the user details from the team henceforth
    self.selected_user = user.company.users.find_by(id: id)
  end

  def validate
    if selected_user.blank?
      add_message :error, "User not found, reload and try again"
    end
  end

  def process
    credit_actions = {initiating_accounts: [], receiving_accounts: []}
    debit_actions = {initiating_accounts: [], receiving_accounts: []}

    # company credits
    if user.company_admin?
      # from account
      company_account_adapter = AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
      action = {type: :company_credits, id: user.company.yes_bank_company_account.id, name: 'Company Credits',
                balance: company_account_adapter.balance}
      credit_actions[:initiating_accounts] << action
      debit_actions[:initiating_accounts] << action
    end

    # from account
    source_wallet_adapter = AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
    action = {type: :vendor_wallet, id: user.bank_wallet.id, name: "#{user.name}'s Finly Bank Wallet",
              balance: source_wallet_adapter.balance
              }
    credit_actions[:initiating_accounts] << action
    debit_actions[:initiating_accounts] << action

    # to account - always receiving user's wallet
    receiving_wallet_adapter = AccountManager::BankWallet::VendorPaymentWalletAdapter.new(selected_user.bank_wallet)
    action = {type: :vendor_wallet, id: selected_user.bank_wallet.id, name: "#{selected_user.name}'s Finly Bank Wallet",
              balance: receiving_wallet_adapter.balance
    }
    credit_actions[:receiving_accounts] << action
    debit_actions[:receiving_accounts] << action

    self.transfer_options = {transfer_options: {meta: {base_url: Rails.application.routes.url_helpers.bank_transfer_update_balance_path(receiving_user_id: selected_user.id, view: params[:view])}, credit: true, debit: true, credit_actions: credit_actions, debit_actions: debit_actions}}
  end

  def success
    params[:transfer_options] = self.transfer_options
    BankTransfer::VendorPaymentWallet::TransferOptions::ActionsPresenter.new(user, params, messages)
  end


  class BankTransfer::VendorPaymentWallet::TransferOptions::ActionsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :transfer_options

    def init
      self.transfer_options = params[:transfer_options]
    end
  end
end