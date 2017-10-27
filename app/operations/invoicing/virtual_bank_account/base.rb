class Invoicing::VirtualBankAccount::Base < BaseOperation

  class Invoicing::VirtualBankAccount::Base::VirtualAccountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :virtual_bank_account, :company

    def init
      self.virtual_bank_account = params[:virtual_bank_account]
      self.company = virtual_bank_account.company
    end

  end

end