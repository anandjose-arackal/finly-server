class Procure::InwardDocumentsController < BaseControllers::WebBase

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
