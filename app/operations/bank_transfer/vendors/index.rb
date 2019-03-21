class BankTransfer::Vendors::Index < BankTransfer::Vendors::Base

  attr_accessor :vendors

  class BankTransfer::Vendors::Index::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendors

    has_scope :filter_name_search

    def init
      self.vendors = params[:vendors]
      unless params[:without_bank_accounts]
        self.vendors = self.vendors.includes_bank_accounts
      end
      self.vendors = apply_scopes(self.vendors, params).paginate(page: params[:page], per_page: 30)
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