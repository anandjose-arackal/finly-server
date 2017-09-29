class BankTransfer::AccountOwners::Index < BankTransfer::AccountOwners::Base

  attr_accessor :account_owners, :beneficiary_type

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
    if params[:beneficiary_type].blank?
      add_message :error, "You have to choose at least one beneficiary type"
      return
    end
  end

  def init
    self.company = user.company
    self.beneficiary_type = params[:beneficiary_type]
  end

  def process
    # todo - based on the type, send vendors or employees
    case self.beneficiary_type
      when 1, '1'
        self.account_owners = company.users
      when 2, '2'
        self.account_owners = company.yes_bank_vendors
      else
        # do nothing?
    end
  end

  def success
    params[:account_owners] = self.account_owners
    BankTransfer::AccountOwners::Index::AccountOwnersPresenter.new(user, params, messages)
  end

  class BankTransfer::AccountOwners::Index::AccountOwnersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :account_owners, :paginated_account_owners

    def init
      self.account_owners = params[:account_owners]
      self.paginated_account_owners = account_owners.paginate(page: params[:page], per_page: params[:per_page] || 30)
    end
  end
end