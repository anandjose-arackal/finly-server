class BankTransfer::Vendors::UploadAttachments < BankTransfer::Vendors::Base

  attr_accessor :vendor, :attachment_params, :vendor_attachment

  def init
    id = params[:id] || params[:yes_bank_vendor_id]
    self.attachment_params = attachment_attributes
    self.vendor = YesBankVendor.find_by(id: id)

    self.vendor_attachment = vendor.vendor_attachments.find_by id: attachment_params[:id]
  end

  def validate
    if vendor.blank?
      add_message :error, "Vendor not found"
    end
  end

  def process
    if vendor_attachment.present?
      self.vendor_attachment.assign_attributes(attachment_params)
    else
      self.vendor_attachment = vendor.vendor_attachment.build(attachment_params)
    end

    if vendor_attachment.valid?
      vendor_attachment.save
    else
      add_message :error, vendor_attachment.errors.full_messages
    end

  end

  def post_process
    add_message :success, "Successfully updated attachment"
  end

  def attachment_attributes
    params.require(:vendor_attachment).permit(:id, :attachment_file, :attachment_type)
  end
end