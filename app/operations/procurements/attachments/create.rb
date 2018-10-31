class Procurements::Attachments::Create < Procurements::Attachments::Base
  attr_accessor :attachment_params, :attachment

  def init
    self.attachment_params = attachment_parameters
  end

  def process
    self.attachment = user.procurement_attachments.new(attachment_params)
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

  private

  def attachment_parameters
    params.require(:attachment).permit(:file, :name, :description)
  end
end