class BankTransfer::VendorTypes::Index < BankTransfer::VendorTypes::Base
  attr_accessor :vendor_types

  def init
    self.vendor_types = user.company.vendor_types
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def success
    params[:vendor_types] = self.vendor_types
    BankTransfer::VendorTypes::Index::IndexPresenter.new(user, params, messages)
  end

  class BankTransfer::VendorTypes::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :vendor_types

    def init
      self.vendor_types = params[:vendor_types]
    end
  end
end