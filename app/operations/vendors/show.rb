class Vendors::Show < Vendors::Base

  attr_accessor :vendor, :receiving_transactions, :bank_accounts, :actions

  def init
    id = params[:vendor_id] || params[:yes_bank_vendor_id] || params[:id] 
    self.vendor = user.company.yes_bank_vendors.with_id(id).includes_for_show.first rescue nil
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

    attr_accessor :receiving_transactions, :bank_accounts, :vendor, :actions,
                  :custom_fields, :edit_config, :reviewal_chain, :vendor_approval_workflow

    def init
      self.receiving_transactions = params[:receiving_transactions]
      self.bank_accounts = params[:bank_accounts]
      self.vendor = params[:vendor]
      self.vendor_approval_workflow = user.company.vendor_empanelment_workflow_enabled?

      # self.actions = get_actions
      self.edit_config = Vendors::NewVendorConfig.(self.vendor.created_by, params)

      if self.vendor.is_a?(YesBankVendor)
        # self.procurement_data = get_procurement_data
        self.custom_fields = self.vendor.custom_fields
      end
    end
  end
end