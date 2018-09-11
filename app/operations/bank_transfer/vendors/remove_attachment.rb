class BankTransfer::Vendors::RemoveAttachment < BankTransfer::Vendors::Base

  attr_accessor :vendor, :attachment

  def init
    id = params[:id] || params[:vendor_id] || params[:yes_bank_vendor_id]
    self.vendor = YesBankVendor.find_by(id: id)
    self.attachment = vendor.vendor_attachments.find_by id: params[:attachment_id]
  end

  def validate
    if vendor.blank?
      add_message :error, "Vendor not found"
    end

    if attachment.blank?
      add_message :error, 'Attachment not found'
    end
  end

  def process
    self.attachment.destroy
  end

  def post_process
    add_message :success, "Removed Attachment"
  end
end