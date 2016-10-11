class User::PrepaidCard::Funds::Base < User::PrepaidCard::Base
attr_accessor :payment

ACTIONS = {credit: 1, debit: 2, transfer: 3, withdraw: 4}

  def success
    User::PrepaidCard::Funds::Base::SuccessPresenter.(user, {payment: self.payment}, messages)
  end

  class User::PrepaidCard::Funds::Base::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end

  end

end