class Invoicing::VirtualBankAccount::Index < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_accounts, :company, :role_id

  class Invoicing::VirtualBankAccount::Index::AccountsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :virtual_bank_accounts, :paginated_virtual_bank_accounts, :count

    has_scope :filter_search
    has_scope :filter_created_by_id

    def init
      self.virtual_bank_accounts = params[:virtual_bank_accounts]
      self.virtual_bank_accounts = apply_scopes(self.virtual_bank_accounts, params)
      self.paginated_virtual_bank_accounts = virtual_bank_accounts.paginate(page: params[:page], per_page: params[:per_page])
      self.count = self.virtual_bank_accounts.count
    end
  end


  def init
    self.role_id = UserRole::VALUES[params[:view]&.to_sym]
    if self.role_id.blank?
      self.role_id = UserRole.id_for(:personal)
    end
    self.company = user.company
  end

  def validate

  end

  def process
    case self.role_id
      when UserRole.id_for(:admin)
        self.virtual_accounts = self.company.virtual_bank_accounts
      # when UserRole.id_for(:reviewer), UserRole.id_for(:initiator)
      #   self.virtual_accounts = self.user.virtual_bank_accounts
      else
        # self.virtual_accounts = self.user.virtual_bank_accounts
        self.virtual_accounts = self.company.virtual_bank_accounts
    end
  end

  def post_process

  end

  def success
    params[:virtual_bank_accounts] = self.virtual_accounts
    Invoicing::VirtualBankAccount::Index::AccountsPresenter.new(user, params, messages)
  end
end