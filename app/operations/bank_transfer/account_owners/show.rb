class BankTransfer::AccountOwners::Show < BankTransfer::AccountOwners::Base

  attr_accessor :account_owner, :receiving_transactions, :bank_accounts, :actions

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
    self.receiving_transactions = account_owner.receiving_payments.with_receiving_user_type(self.account_owner.class.name).with_receiving_account_type("BankAccount").with_application(RequestStore.store[:current_app]).successful_and_failed_only
  end

  def success
    params[:receiving_transactions] = receiving_transactions
    params[:bank_accounts] = bank_accounts
    params[:account_owner] = account_owner
    BankTransfer::Vendors::Transfers::Show::AccountOwnersPresenter.new(user, params)
  end

  class BankTransfer::Vendors::Transfers::Show::AccountOwnersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receiving_transactions, :bank_accounts, :account_owner, :actions, :procurement_data,
                  :custom_fields

    def init
      self.receiving_transactions = params[:receiving_transactions]
      self.bank_accounts = params[:bank_accounts]
      self.account_owner = params[:account_owner]

      self.actions = get_actions

      if self.account_owner.is_a?(YesBankVendor)
        self.procurement_data = get_procurement_data
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

    def get_procurement_data
      data = {}

      data[:purchase_orders] = PurchaseOrder.where(vendor_id: self.account_owner.id)
      data[:non_po_invoices] = Invoice.filter_inward_invoice_type(:non_po_invoice).with_vendor_ids(self.account_owner.id)

      data

    end

  end

end