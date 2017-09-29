class BankTransfer::AccountOwners::Index < BankTransfer::AccountOwners::Base

  attr_accessor :vendors

  def init
    self.company = user.company
  end

  def process
    # todo - based on the type, send vendors or employees
    self.vendors = company.yes_bank_vendors
  end

  def success
    params[:vendors] = vendors
    BankTransfer::AccountOwners::Index::AccountOwnerssPresenter.new(user, params, messages)
  end

  class BankTransfer::AccountOwners::Index::AccountOwnerssPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendors, :paginated_vendors

    def init
      self.vendors = params[:vendors]
      self.paginated_vendors = vendors.paginate(page: params[:page], per_page: params[:per_page] || 30)
    end
  end
end