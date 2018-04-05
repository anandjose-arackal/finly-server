class Invoicing::VirtualBankAccount::Count< Invoicing::VirtualBankAccount::Base

  attr_accessor :count

  class Invoicing::VirtualBankAccount::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end

  end


  def process
    result = Invoicing::VirtualBankAccount::Index.(user, params)
    if result.success?
      self.count = result.virtual_bank_accounts.count
    else
      add_message :error, result.messages[:error]
    end
  end

  def success
    params[:count] = self.count
    Invoicing::VirtualBankAccount::Count::CountPresenter.new(user, params, messages)
  end
end