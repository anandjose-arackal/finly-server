class Invoicing::Customer::Index < Invoicing::Customer::Base

  attr_accessor :company, :customers

  class Invoicing::Customer::Index::CustomersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :customers, :paginated_customers

    def init
      self.customers = params[:customers]
      self.paginated_customers = customers.paginate(page: params[:page], per_page: params[:per_page])
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