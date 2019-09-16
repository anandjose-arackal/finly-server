class TravelRequestDestinationsController < BaseControllers::WebBase


  def create
    @result = TravelRequests::Destinations::Create.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end

  def update
    @result = TravelRequests::Destinations::Update.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end

  def destroy
    @result = TravelRequests::Destinations::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end

end
