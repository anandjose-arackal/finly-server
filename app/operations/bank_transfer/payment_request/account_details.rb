# this operation takes a bunch of account ids and returns the bank details of all those
# accounts from the database
# params: {
#   account_owner_type: 1 for User, 2 for YesBankVendor
#   array of bank account ids
# }

class BankTransfer::PaymentRequest::AccountDetails < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_accounts, :account_ids, :invoice_categories, :invoice_item_categories

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.account_ids = params[:account_ids]
  end

  def process
    self.bank_accounts = user.company.bank_accounts.with_owner_ids(params[:account_owner_type], account_ids)
    self.invoice_categories = current_company.vendor_payments_only
    self.invoice_item_categories = current_company.categories.inward_invoice_items_only
  end

  def success
    params[:bank_accounts] = bank_accounts
    params[:invoice_categories] = self.invoice_categories
    params[:invoice_item_categories] = self.invoice_item_categories
    BankTransfer::PaymentRequest::AccountDetails::AccountsPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::AccountDetails::AccountsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_accounts, :custom_fields_config, :invoice_categories, :invoice_item_categories

    def init
      self.bank_accounts = params[:bank_accounts]
      self.custom_fields_config = {
          invoice: user.company.field_configurations.exclude_deleted.with_parent_type(FieldParentType.id_for(:invoice))
      }
      self.invoice_categories = params[:invoice_categories]
      self.invoice_item_categories = params[:invoice_item_categories]
    end
  end

end