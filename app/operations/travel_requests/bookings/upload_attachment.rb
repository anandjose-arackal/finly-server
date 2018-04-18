class TravelRequests::Bookings::UploadAttachment < TravelRequests::Bookings::Base
  attr_accessor :attachment_parameters, :booking_attachment

  class TravelRequests::Bookings::UploadAttachment::AttachmentPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :attachment

    def init
      self.attachment = params[:booking_attachment]
    end
  end

  def init

    self.attachment_parameters = attachment_params
  end

  def validate

  end

  def pre_process

    self.attachment_parameters[:user_id] = user.id
  end

  def process
    self.booking_attachment = user.company.booking_attachments.build(attachment_parameters)

    unless booking_attachment.save
      add_message :error, booking_attachment.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Attachment Uploaded"
  end

  def success
    params[:booking_attachment] = self.booking_attachment
    TravelRequests::Bookings::UploadAttachment::AttachmentPresenter.new(user, params, messages)
  end

  private

  def attachment_params
    params.require(:booking).permit(:attachment, :description)
  end


end