class TravelRequestBookingsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def create
    @result = TravelRequests::Bookings::Create.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end

  def update
    @result = TravelRequests::Bookings::Update.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end

  def destroy
    @result = TravelRequests::Bookings::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end

end
