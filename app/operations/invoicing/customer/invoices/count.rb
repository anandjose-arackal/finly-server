class Invoicing::Customer::Invoices::Count < Invoicing::Customer::Base

  attr_accessor :count

  class Invoicing::Customer::Invoices::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end
  end

  def init
    op = Invoicing::Customer::Invoices::Index.(user, params)
    self.count = op.invoices_paid.count
  end

  def success
    params[:count] = self.count
    Invoicing::Customer::Invoices::Count::CountPresenter.new(user, params, messages)
  end

end