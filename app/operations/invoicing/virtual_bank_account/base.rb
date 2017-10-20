class Invoicing::VirtualBankAccount::Base < BaseOperation

  class Invoicing::VirtualBankAccount::Base::VirtualAccountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :virtual_bank_account

    def init
      self.virtual_bank_account = params[:virtual_bank_account]
    end

  end

end