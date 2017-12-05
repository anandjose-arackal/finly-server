class Invoicing::PaymentReceivable::Public::Show < Invoicing::PaymentReceivable::Base

  attr_accessor :payment_receivable

  def init
    acc_number = params[:virtual_account_number]
    bank_account = VirtualBankAccount.find_by(account_number: acc_number)
    self.payment_receivable = bank_account.parent
  end

  def process

  end

  def success
    params[:payment_receivable] = self.payment_receivable
    Invoicing::PaymentReceivable::Base::ReceivablePresenter.new(user, params, messages)
  end
end