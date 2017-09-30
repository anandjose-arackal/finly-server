class BankTransfer::Vendors::Destroy < BankTransfer::Vendors::Base

  def init
    id = params[:id] || params[:vendor_id]
    self.vendor = YesBankVendor.find_by(id: id)
  end

  def validate
    if self.vendor.blank?
      add_message :error, "Vendor not found"
    end
  end

  def process
    unless self.vendor.update(is_deleted: true)
      add_message :error, self.vendor.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Vendor successfully destroyed"
  end

end