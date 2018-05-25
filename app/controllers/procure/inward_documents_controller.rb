class Procure::InwardDocumentsController < ApplicationController
  before_action -> {finly_authorize! :web}

  def create
    @result = Procurements::InwardDocuments::Create.(current_user, params)
    respond
  end
end