class UniqueIdentifiersController < BaseControllers::WebBase

  def index
    @result = UniqueIdentifier::Index.(current_user, params)
    respond
  end

  def update
    @result = UniqueIdentifier::Set.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end
