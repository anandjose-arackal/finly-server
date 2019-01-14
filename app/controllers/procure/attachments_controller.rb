class Procure::AttachmentsController < BaseControllers::WebBase

  def index
    @result = Procurements::Attachments::Index.(current_user, params)
    respond
  end

  def destroy
    @result = Procurements::Attachments::Destroy.(current_user, params)
    respond
  end

  def create
    @result = Procurements::Attachments::Create.(current_user, params)
    respond
  end


end
