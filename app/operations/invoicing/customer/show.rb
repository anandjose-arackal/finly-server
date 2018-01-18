class Invoicing::Customer::Show < Invoicing::Customer::Base

  attr_accessor :customer, :payments

  class Invoicing::Customer::Show::CustomerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :customer, :payments

    def init
      self.customer = params[:customer]
      self.payments = params[:payments]
    end

  end

  def init
    id = params[:customer_id] || params[:id]
    self.customer = user.company.customers.find_by(id: id)
  end

  def process
    # extracting payments made by the particular customer to this company
    # todo - the below is just a sample for how the call will look like
    # self.payments = Invoicing::Customer::Payments::Show.(self.customer)
    self.payments = []
  end

  def  post_process

  end

  def success
    params[:customer] = self.customer
    params[:payments] = self.payments
    Invoicing::Customer::Show::CustomerPresenter.new(user, params, messages)
  end
end