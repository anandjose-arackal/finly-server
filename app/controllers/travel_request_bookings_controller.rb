class TravelRequestBookingsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def create
    @result = TravelRequests::Bookings::Create.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

  def update
    @result = TravelRequests::Bookings::Update.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

  def destroy
    @result = TravelRequests::Bookings::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

  def select_option
    @result = TravelRequests::Bookings::SelectOption.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

  def unselect_option
    @result = TravelRequests::Bookings::UnselectOption.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

  def cancel
    @result = TravelRequests::Bookings::Cancel.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

  def mark_as_unavailable
    @result = TravelRequests::Bookings::MarkAsUnavailable.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

  def reject_booking_request
    @result = TravelRequests::Review::RejectBookingRequest.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

end
