class BankTransfer::Autocomplete::Vendors < BankTransfer::Autocomplete::Base

  attr_accessor :account_owner, :bank_accounts, :actions

  def init
    super()
    id = params[:id] || params[:account_owner_id]
    case params[:beneficiary_type]
      when '2', 2
        self.account_owner = company.yes_bank_vendors.find_by(id: id)
      when 1, '1'
        self.account_owner = company.users.find_by(id: id)
      else
        # by default it goes to vendors
        self.account_owner = company.yes_bank_vendors.find_by(id: id)
    end
  end

  def validate
    if account_owner.blank?
      add_message :error, "Owner not found"
    end
  end

  def process
    self.bank_accounts = account_owner.bank_accounts.non_deleted
    
  end

  def success
    params[:bank_accounts] = bank_accounts
    params[:account_owner] = account_owner
    BankTransfer::Autocomplete::Vendors::SuccessPresenter.new(user, params)
  end

  class BankTransfer::Autocomplete::Vendors::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_accounts, :account_owner, :actions,
                  :custom_fields

    def init
      self.bank_accounts = params[:bank_accounts]
      self.account_owner = params[:account_owner]

      self.actions = get_actions

      if self.account_owner.is_a?(YesBankVendor)
        self.custom_fields = self.account_owner.custom_fields
      end
    end


    def get_actions
      actions = {}

      if account_owner.is_a?(YesBankVendor)
        actions[:create_beneficiaries] = user.permission.create_beneficiaries
      end

      actions
    end

  end

end
