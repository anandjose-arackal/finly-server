# this operation takes an amount, and a vendor account ID (or a vendor ID) and adds the respective amount to the
# particular vendor's account and also creates a vendor account transaction to boot
# typically called by another operation, but can be standalone too

class BankTransfer::Vendors::VendorAccount::Add < BankTransfer::Vendors::VendorAccount::Base

  attr_accessor :vendor_account, :transaction_amount

  def init
    vendor_id = params[:vendor_id]
    vendor = user.company.yes_bank_vendors.find_by(id: vendor_id)
    self.vendor_account = vendor&.vendor_account
    if self.vendor_account.blank?
      vendor_account_id = params[:vendor_account_id]
      self.vendor_account = VendorAccount.with_vendor_id(user.company.yes_bank_vendors.pluck(:id)).find_by(id: vendor_account_id)
    end
    self.transaction_amount = params[:transaction_amount].to_f
  end

  def validate
    if self.vendor_account.blank?
      add_message :error, "Vendor account not found"
      return
    end
    if self.transaction_amount.blank? || self.transaction_amount <= 0
      add_message :error, "Invalid transaction amount"
    end
  end

  def process

  end

end