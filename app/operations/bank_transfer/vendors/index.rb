class BankTransfer::Vendors::Index < BankTransfer::Vendors::Base

  attr_accessor :vendors

  class BankTransfer::Vendors::Index::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendors

    has_scope :filter_name_search

    def init
      self.vendors = params[:vendors]
      self.vendors = apply_scopes(self.vendors, params)

      per_page = params[:per_page] || 30
      page = params[:page] || 1
      self.vendors = self.vendors.paginate(per_page: per_page, page: page).includes_bank_accounts
    end

  end

  def init
    self.vendors = user.company.yes_bank_vendors.non_deleted
  end

  def success
    params[:vendors] = self.vendors
    BankTransfer::Vendors::Index::VendorsPresenter.new(user, params, messages)
  end

end