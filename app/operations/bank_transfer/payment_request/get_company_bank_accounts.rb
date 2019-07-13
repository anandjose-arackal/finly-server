class BankTransfer::PaymentRequest::GetCompanyBankAccounts < BankTransfer::PaymentRequest::Base
  def authorized_user_types
  end

  def pre_validate
  end

  def init
  end

  def success
    BankTransfer::PaymentRequest::GetCompanyBankAccounts::Presenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::GetCompanyBankAccounts::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :bank_accounts

    def init
      self.bank_accounts = []

      bank_accounts_op = AccountManager::CompanyBankAccounts::Index.(user, {balance: true})

      if bank_accounts_op.success?
        self.bank_accounts = bank_accounts_op.bank_accounts
      end
    end
  end
end