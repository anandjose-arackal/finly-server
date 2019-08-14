class AdminUsers::ImplementationsController < BaseControllers::AdminBase
  protect_from_forgery with: :null_session
  def create
    @result = Admin::Implementations::RequestHandler.(current_user, params)
    respond
  end

  def index
    @result = Admin::Implementations::Index.(current_user, params)
    respond
  end

  def show

  end

end
