class BankTransfer::Vendors::Destroy < BankTransfer::Vendors::Base

  def init
    id = params[:id] || params[:vendor_id]
    self.vendor = YesBankVendor.find_by(id: id)
  end

  def process
    unless self.vendor.destroy
      add_message :error, self.vendor.errors.full_messages
    end
  end

  def post_process
    add_message :error, "Vendor successfully destroyed"
  end

end