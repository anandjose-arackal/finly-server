class Vendors::Index < Vendors::Base

  attr_accessor :vendors

  class Vendors::Index::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter

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

  def validate
    #
  end

  def success
    params[:vendors] = self.vendors
    Vendors::Index::VendorsPresenter.new(user, params, messages)
  end

end