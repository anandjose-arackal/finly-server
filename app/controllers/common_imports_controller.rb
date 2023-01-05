class CommonImportsController < BaseControllers::WebBase

  before_action :add_company

  def add_company
    params[:company_id] = current_user.company
  end

  def create
    @result = CommonImports::RequestHandler.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def index
    @result = CommonImports::Index.(current_user, params)
    respond
  end

  def get_template
    @result = CommonImports::ImportTemplate.(current_user, params)
    respond
  end

end
