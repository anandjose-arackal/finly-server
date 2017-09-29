class BankTransfer::Vendor::Index < BankTransfer::Vendor::Base

  attr_accessor :vendors

  def init
    self.company = user.company
  end

  def process
    # todo - in the future, with finance and manager view, we can implement team view for vendors and shit
    self.vendors = company.yes_bank_vendors
  end

  def success
    params[:vendors] = vendors
    BankTransfer::Vendor::Index::VendorsPresenter.new(user, params, messages)
  end

  class BankTransfer::Vendor::Index::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendors, :paginated_vendors

    def init
      self.vendors = params[:vendors]
      self.paginated_vendors = vendors.paginate(page: params[:page], per_page: params[:per_page] || 30)
    end
  end
end