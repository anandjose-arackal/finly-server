class Procure::InwardDocumentsController < BaseControllers::WebBase
  before_action -> {finly_authorize! :web}

  def show
    @result = Procurements::InwardDocuments::Show.(current_user, params)
    respond
  end

  def create
    @result = Procurements::InwardDocuments::Create.(current_user, params)
    respond
  end

  def update
    @result = Procurements::InwardDocuments::Update.(current_user, params)
    respond
  end
end
