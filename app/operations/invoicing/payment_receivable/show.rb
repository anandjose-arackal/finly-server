class Invoicing::PaymentReceivable::Show < Invoicing::PaymentReceivable::Base

  attr_accessor :payment_receivable

  def init
    id = params[:id] || params[:payment_receivable_id]
    self.payment_receivable = Invoicing::PaymentReceivable::Index.(user, params).receivables.find_by(id: id) rescue nil
  end

  def validate
    if self.payment_receivable.blank?
      add_message :error, "Payment Receivable not found"
    end
  end

  def process

  end

  def success
    params[:payment_receivable] = self.payment_receivable
    params[:virtual_bank_account] = self.payment_receivable.virtual_bank_account
    Invoicing::PaymentReceivable::Base::ReceivablePresenter.new(user, params, messages)
  end

end