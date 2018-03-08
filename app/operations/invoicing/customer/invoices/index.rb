class Invoicing::Customer::Invoices::Index < Invoicing::Customer::Base

  attr_accessor :invoices_paid

  class Invoicing::Customer::Invoices::Index::InvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices_paid

    def init
      self.invoices_paid = params[:invoices_paid]
    end
  end

  def init
    id = params[:customer_id] || params[:id]
    self.customer = user.company.customers.find_by(id: id)
  end

  def validate
    if self.customer.blank?
      add_message :error, "Customer not found"
      return
    end
  end

  def process
    self.invoices_paid = self.customer.outward_invoices.processed
  end

  def success
    params[:invoices_paid] = self.invoices_paid
    Invoicing::Customer::Invoices::Index::InvoicesPresenter.new(user, params, messages)
  end

end