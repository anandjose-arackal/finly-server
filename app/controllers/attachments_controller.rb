class AttachmentsController < BaseControllers::WebBase

  def index
    @result = Attachments::Index.(current_user, params)
    respond
  end

  def create
    @result = Attachments::Create.(current_user, params)
    respond
  end

  def create_custom_field_attachment
    @result = Attachments::CreateCustomFieldAttachment.(current_user, params)
    respond
  end

  def destroy
    @result = Attachments::Destroy.(current_user, params)
    respond
  end

end