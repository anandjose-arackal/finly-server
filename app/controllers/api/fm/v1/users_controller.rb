class Api::Fm::V1::UsersController < ApiApplicationController

  before_action -> { finly_authorize! :api,}

  def create
    formatted_params = RequestFormatter::ApiParser::FmParser::V1::Users::Create.(current_user, params).formatted_request
    @result = User::Create.(current_user, formatted_params)
    respond response: (@result&.success? ? :success : :failure)
  end

  def index
    @result = User::Index.(current_user, params)
    respond
  end

  def show
    @result = User::Show.(current_user, params)
    respond
  end

  def update
    params[:validate_password] = false
    unless params[:type]
      respond(response: :failure, message: 'Error while updating status. Type not found')
      return
    end
    operation = nil
    success_message = nil
    case params[:type]
      when 'role'
        formatted_params = RequestFormatter::ApiParser::FmParser::V1::Users::UpdateRole.(current_user, params).formatted_request
        operation = User::Role::Set.new(current_user, formatted_params)
        success_message = 'Role updated'
      when 'state', 'status'
        operation = User::Configuration::UpdateState.new(current_user, params)
        success_message = 'Status updated'
      else
        # do nothing, ha!
    end
    unless operation.present?
      respond(response: :failure, message: 'Error while updating status. Invalid type')
      return
    end
    @result = operation.run
    if @result&.success?
      respond(response: :success, message: success_message)
    else
      respond response: :failure, message: (@result&.messages[:error] || 'Error while updating data')
    end
  end

end
