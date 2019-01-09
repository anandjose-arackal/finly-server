class Invoicing::Customer::Index < Invoicing::Customer::Base

  attr_accessor :company, :customers

  class Invoicing::Customer::Index::CustomersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :customers, :paginated_customers, :count

    has_scope :filter_search
    has_scope :search_by_virtual_accounts
    has_scope :virtual_accounts_presence

    def init
      self.customers = params[:customers]
      self.customers = apply_scopes(self.customers, params)
      self.paginated_customers = customers.paginate(page: params[:page], per_page: params[:per_page])
      self.count = self.customers.count
    end

  end

  def init
    self.company = user.company
  end

  def process
    self.customers = self.company.customers.active
  end

  def success
    params[:customers] = self.customers
    Invoicing::Customer::Index::CustomersPresenter.new(user, params, messages)
  end
end