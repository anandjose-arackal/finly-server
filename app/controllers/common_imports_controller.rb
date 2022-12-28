class CommonImportsController < BaseControllers::WebBase

  ALLOWED_IMPORT_TYPES = %w[ lrms lurms ]
  before_action :authorize_common_import

  def authorize_common_import
    import_type = params&[:request_key].to_s.split(".")[0]
    unless current_user.admin? and ALLOWED_IMPORT_TYPES.includes? import_type
      head 403
    end
  end

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

end
