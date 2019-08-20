class AdminUsers::ImplementationsController < BaseControllers::AdminBase
  protect_from_forgery with: :null_session
  def create
    @result = Admin::Implementations::RequestHandler.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = Admin::Implementations::Index.(current_user, params)
    respond
  end

  def get_template
    @result = Admin::Implementations::ImportTemplate.(current_user, params)
    respond
  end

  def show

  end

end
