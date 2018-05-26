class Procure::AttachmentsController < ApplicationController
  before_action -> {finly_authorize! :web}

  def create
    @result = Procurements::Attachments::Create.(current_user, params)
    respond
  end
end