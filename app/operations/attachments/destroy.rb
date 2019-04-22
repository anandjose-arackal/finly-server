class Attachments::Destroy < Attachments::Base

  attr_accessor :attachment

  def init
    id = params[:id] || params[:attachment_id]
    self.attachment = user.company.attachments.with_id(id).first
  end

  def validate
    unless self.attachment.present?
      add_message :error, 'Attachment not found'
    end
  end

  def process
    if self.attachment.destroy
      add_message :success, 'Successfully deleted attachment'
    else
      add_message :error, 'Could not deleted attachment'
    end

  end

end