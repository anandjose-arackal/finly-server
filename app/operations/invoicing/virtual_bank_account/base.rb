class Invoicing::VirtualBankAccount::Base < BaseOperation

  attr_accessor :virtual_bank_account

  class Invoicing::VirtualBankAccount::Base::VirtualAccountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :virtual_bank_account, :company

    def init
      self.virtual_bank_account = params[:virtual_bank_account]
      self.company = virtual_bank_account.company
    end

  end

  def init
    id = params[:id] || params[:virtual_bank_account_id]
    self.virtual_bank_account = Invoicing::VirtualBankAccount::Index.(user, params).virtual_bank_accounts.find_by(id: id) rescue nil
  end

end