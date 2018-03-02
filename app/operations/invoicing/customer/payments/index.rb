class Invoicing::Customer::Payments::Index < Invoicing::Customer::Base

  attr_accessor :payments_received

  class Invoicing::Customer::Payments::Index::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payments_received

    def init
      self.payments_received = params[:payments_received]
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
    customer_virtual_account_ids = self.customer.virtual_bank_accounts.pluck(:id)
    self.payments_received = ::Payment.with_initiating_account_type("VirtualBankAccount").with_initiating_account_id(customer_virtual_account_ids)
  end

  def success
    params[:payments_received] = self.payments_received
    Invoicing::Customer::Payments::Index::PaymentsPresenter.new(user, params, messages)
  end
end