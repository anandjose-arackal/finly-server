class Invoicing::PaymentReceivable::Index < Invoicing::PaymentReceivable::Base

  attr_accessor :receivables

  class Invoicing::PaymentReceivable::Index::ReceivablesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receivables

    def init
      self.receivables = params[:receivables]
    end

  end

  def init

  end

  def process

  end

  def success
    params[:receivables] = ::PaymentReceivable.all
    Invoicing::PaymentReceivable::Index::ReceivablesPresenter.new(user, params, messages)
  end
end