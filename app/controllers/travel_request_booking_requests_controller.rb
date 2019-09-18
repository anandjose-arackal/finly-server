class TravelRequestBookingRequestsController < BaseControllers::WebBase


  def create
    @result = TravelRequests::BookingRequests::Create.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end

  def update
    @result = TravelRequests::BookingRequests::Update.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end

  def destroy
    @result = TravelRequests::BookingRequests::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end

end
