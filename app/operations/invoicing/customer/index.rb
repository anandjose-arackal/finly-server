class Invoicing::Customer::Index < Invoicing::Customer::Base

  attr_accessor :company, :customers

  class Invoicing::Customer::Index::CustomersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :customers

    def init
      self.customers = params[:customers]
    end

  end

  def init
    self.company = user.company
  end

  def process
    self.customers = self.company.customers
  end

  def success
    params[:customers] = self.customers
    Invoicing::Customer::Index::CustomersPresenter.new(user, params, messages)
  end
end