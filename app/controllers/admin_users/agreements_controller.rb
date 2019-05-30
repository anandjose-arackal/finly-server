class AdminUsers::AgreementsController < BaseControllers::AdminBase


  def create
    @result = Admin::Agreement::Create.(current_user, params)
    respond response: (@result.success? ? :success : :failure)
  end

  def index
    @result = Admin::Agreement::Index.(current_user, params)
    respond
  end

end
