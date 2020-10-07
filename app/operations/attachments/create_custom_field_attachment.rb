class Attachments::CreateCustomFieldAttachment < Attachments::Base

  attr_accessor :attachment

  def init
  end

  def process
    self.attachment = CustomFieldAttachment.new
    self.attachment.attachment = params[:file]
    # self.attachment.creator_id = user.id
    # self.attachment.company = user.company
    # self.attachment.resource_type = params[:resource_type] if params[:resource_type].present?
    # self.attachment.resource_id = params[:resource_id] if params[:resource_id].present?
    if self.attachment.save
      add_message :success, 'Upload Successful'
    else
      add_message :error, attachment.errors.full_messages
      return
    end

  end

  def success
    params[:attachment] = self.attachment
    Attachments::CreateCustomFieldAttachment::CreatePresenter.new(user, params, messages)
  end

  class Attachments::CreateCustomFieldAttachment::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :attachment

    def init
      self.attachment = params[:attachment]
    end
  end

  def attachment_params
    # params.require(:attachment).permit(:description, :resource_type, :resource_id, :file_file_name, :file_file_size, :file_content_type, :file_updated_at, :attachment)
    params.permit(:attachment, :attachment_file_name, :attachment_file_size, :attachment_content_type, :attachment_updated_at)
  end

end