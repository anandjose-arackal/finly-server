class Attachments::Create < Attachments::Base

  attr_accessor :attachment

  def init
  end

  def process
    self.attachment = Attachment.new
    self.attachment.file = params[:attachment]
    self.attachment.creator_id = user.id
    self.attachment.company = user.company

    if self.attachment.save
      add_message :success, 'Upload Successful'
    else
      add_message :error, attachment.errors.full_messages
      return
    end

  end

  def success
    params[:attachment] = self.attachment
    Procurements::Attachments::Create::CreatePresenter.new(user, params, messages)
  end

  class Procurements::Attachments::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :attachment

    def init
      self.attachment = params[:attachment]
    end
  end

  def attachment_params
    params.require(:attachment).permit(:description, :resource_type, :resource_id, :file_file_name, :file_file_size, :file_content_type, :file_updated_at, :attachment)
  end

end