class Vendors::Show < Vendors::Base

  attr_accessor :vendor, :receiving_transactions, :bank_accounts, :actions

  def init
    id = params[:vendor_id] || params[:yes_bank_vendor_id] || params[:id] 
    self.vendor = user.company.yes_bank_vendors.find_by(id: id)
  end

  def process
    self.bank_accounts = vendor.bank_accounts.non_deleted
    self.receiving_transactions = vendor.receiving_payments.with_receiving_user_type(self.vendor.class.name).with_receiving_account_type("BankAccount").with_application(RequestStore.store[:current_app]).successful_and_failed_only
  end

  def success
    params[:receiving_transactions] = receiving_transactions
    params[:bank_accounts] = bank_accounts
    params[:vendor] = vendor
    Vendors::Show::ShowPresenter.new(user, params)
  end

  class Vendors::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :receiving_transactions, :bank_accounts, :vendor, :actions, :procurement_data,
                  :custom_fields

    def init
      self.receiving_transactions = params[:receiving_transactions]
      self.bank_accounts = params[:bank_accounts]
      self.vendor = params[:vendor]

      self.actions = get_actions

      if self.vendor.is_a?(YesBankVendor)
        self.procurement_data = get_procurement_data
        self.custom_fields = self.vendor.custom_fields
      end
    end


    def get_actions
      actions = {}

      if vendor.is_a?(YesBankVendor)
        actions[:create_beneficiaries] = user.permission.create_beneficiaries
      end

      actions
    end

    def get_procurement_data
      data = {}

      data[:purchase_orders] = PurchaseOrder.where(vendor_id: self.vendor.id)
      data[:non_po_invoices] = Invoice.filter_inward_invoice_type(:non_po_invoice).with_vendor_ids(self.vendor.id)

      data

    end

  end

end