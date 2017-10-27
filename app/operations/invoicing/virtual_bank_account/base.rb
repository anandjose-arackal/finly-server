class Invoicing::VirtualBankAccount::Base < BaseOperation

  class Invoicing::VirtualBankAccount::Base::VirtualAccountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :virtual_bank_account, :company

    def init
      self.virtual_bank_account = params[:virtual_bank_account]
      self.company = user.company
    end

  end

end