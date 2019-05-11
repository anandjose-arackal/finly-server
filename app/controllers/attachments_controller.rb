class AttachmentsController < WebBase

  def index
    @result = Attachments::Index.(current_user, params)
    respond
  end

  def create
    @result = Attachments::Create.(current_user, params)
    respond
  end

  def destroy
    @result = Attachments::Destroy.(current_user, params)
    respond
  end

end