class BankTransfer::Vendors::Index < BankTransfer::Vendors::Base

  attr_accessor :vendors

  class BankTransfer::Vendors::Index < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendors

    has_scope :filter_search

    def init
      self.vendors = params[:vendors]
    end

  end

  def init
    self.vendors = user.company.yes_bank_vendors
  end

  def success
    params[:vendors] = self.vendors
    BankTransfer::Vendors::Index.new(user, params, messages)
  end

end