class Invoicing::PaymentReceivable::Index < Invoicing::PaymentReceivable::Base

  attr_accessor :receivables, :role_id

  class Invoicing::PaymentReceivable::Index::ReceivablesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receivables

    def init
      self.receivables = params[:receivables]
    end
  end

  def init
    self.role_id = UserRole::VALUES[params[:view].to_sym]
    if self.role_id.blank?
      self.role_id = UserRole.id_for(:initiator)
    end
  end

  def process
    # based on role, retrieve the receivables he has access to
    case self.role_id
      when UserRole.id_for(:initiator)
        self.receivables = user.payment_receivables
      when UserRole.id_for(:reviewer)
        # this is the annoying part todo
      when UserRole.id_for(:admin)
        self.receivables = user.company.payment_receivables
      else
        # sup, we meet again, Oh elusive else
    end
  end

  def success
    params[:receivables] = self.receivables
    Invoicing::PaymentReceivable::Index::ReceivablesPresenter.new(user, params, messages)
  end
end