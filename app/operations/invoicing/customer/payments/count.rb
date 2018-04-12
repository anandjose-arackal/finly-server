class Invoicing::Customer::Payments::Count < Invoicing::Customer::Base

  attr_accessor :count

  class Invoicing::Customer::Payments::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end
  end

  def init
    op = Invoicing::Customer::Payments::Index.(user, params)
    self.count = op.payments_received.count
  end

  def success
    params[:count] = self.count
    Invoicing::Customer::Payments::Count::CountPresenter.new(user, params, messages)
  end

end