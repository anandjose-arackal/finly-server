class BankTransfer::Vendors::NewVendorConfig < BankTransfer::Vendors::Base
  attr_accessor :states, :vendor_types
  def init
    self.states = GstStateCode.all
    self.vendor_types = user.company.vendor_types
  end

  def success
    params[:states] = self.states
    params[:vendor_types] = self.vendor_types
    BankTransfer::Vendors::NewVendorConfig::ConfigPresenter.new(user, params, messages)
  end

  class BankTransfer::Vendors::NewVendorConfig::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :states, :vendor_types

    def init
      self.states = params[:states]
      self.vendor_types = params[:vendor_types]
    end
  end
end