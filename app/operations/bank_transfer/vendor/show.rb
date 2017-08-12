class BankTransfer::Vendor::Show < BankTransfer::Vendor::Base

  attr_accessor :vendor

  def init
    super()
    id = params[:id] || params[:vendor_id]
    self.vendor = company.yes_bank_vendors.find_by(id: id)
  end
end