class Invoicing::InventoryLineItem::UploadAttachments < Invoicing::InventoryLineItem::Base

  attr_accessor :item, :artifact_params, :company_id, :artifact

  def init
    id = params[:id] || params[:invoice_line_item_id]
    self.item = InventoryLineItem.find_by_id id
    self.company_id = user.company_id
    self.artifact_params = artifact_params
  end

  def validate
    if item.blank?
      add_message :error, "Item not found"
      return
    end
  end

  def process
    self.artifact = item.artifacts.build(artifact_params)
  end

  def post_process
    if artifact.valid? && self.artifact.save
        add_message :success, "Upload Successfully"
      else
        add_message :error, artifact.errors.full_messages
    end
  end

  def artifact_params
    params.require(:artifact).permit(:attachment_file_name, :attachment_file_size, :attachment_content_type, :attachment_updated_at, :description, :company_id)
  end
end