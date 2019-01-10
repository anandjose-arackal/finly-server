class BankTransfer::Vendors::Index < BankTransfer::Vendors::Base

  attr_accessor :vendors

  class BankTransfer::Vendors::Index::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendors

    has_scope :filter_name_search

    def init
      self.vendors = params[:vendors]
      self.vendors = apply_scopes(self.vendors, params)
    end

  end

  def init
    self.vendors = user.company.yes_bank_vendors.non_deleted.includes_bank_accounts
  end

  def success
    params[:vendors] = self.vendors
    BankTransfer::Vendors::Index::VendorsPresenter.new(user, params, messages)
  end

end