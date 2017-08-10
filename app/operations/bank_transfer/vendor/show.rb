class BankTransfer::Vendor::Show < BankTransfer::Vendor::Base

  attr_accessor :vendor

  def init
    id = params[:id] || params[:vendor_id]
    self.vendor = YesBankVendor.find_by(id: id)
  end
end