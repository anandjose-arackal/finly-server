class BankTransfer::Vendors::NewVendorConfig < BankTransfer::Vendors::Base
  attr_accessor :states, :vendor_types, :payment_terms, :currencies
  def init
    self.states = GstStateCode.all
    self.vendor_types = user.company.vendor_types
    self.currencies = Currency.all
    self.payment_terms = user.company.payment_terms
  end

  def success
    params[:states] = self.states
    params[:vendor_types] = self.vendor_types
    params[:payment_terms] = self.payment_terms
    params[:currencies] = self.currencies
    BankTransfer::Vendors::NewVendorConfig::ConfigPresenter.new(user, params, messages)
  end

  class BankTransfer::Vendors::NewVendorConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :states, :vendor_types, :currencies, :payment_terms

    def init
      self.states = params[:states]
      self.vendor_types = params[:vendor_types]
      self.currencies = params[:currencies]
      self.payment_terms = params[:payment_terms]
    end
  end
end