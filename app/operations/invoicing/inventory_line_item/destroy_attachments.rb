class Invoicing::InventoryLineItem::DeleteAttachments < Invoicing::InventoryLineItem::Base
  attr_accessor :company_id, :artifact

  def init
    self.artifact = Artifact.find_by_id params[:attachment_id]
  end

  def validate
    if self.artifact.blank?
      add_message :error, "Attachment not found"
      return
    end
  end

  def process
    unless self.artifact.destroy
      add_message :error, "Some error occurred, unable to delete!"
      return
    end
  end

  def post_process
    add_message :success, "Attachment deleted!"
  end
end