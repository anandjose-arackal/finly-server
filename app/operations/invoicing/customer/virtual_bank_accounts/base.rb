class Invoicing::Customer::VirtualBankAccounts::Base < Invoicing::Customer::Base


  class Invoicing::Customer::VirtualBankAccounts::Base::VirtualAccountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :virtual_account

    def init
      self.virtual_account = params[:virtual_account]
    end

  end
end