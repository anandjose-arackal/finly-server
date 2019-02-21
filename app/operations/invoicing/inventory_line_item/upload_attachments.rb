class Invoicing::InventoryLineItem::UploadAttachments < Invoicing::InventoryLineItem::Base

  def validate
    if item.blank?
      add_message :error, "Item not found!"
      return
    end
  end

  def process
    params[:company_id] = company.id
    self.artifact = item.artifacts.build(artifact_params)
  end

  def post_process
    if artifact.valid? && artifact.save
      add_message :success, 'Upload Successful'
    else
      add_message :error, artifact.errors.full_messages
      return
    end
  end

  protected
  def artifact_params
    params.permit(:attachment, :description)
  end
end