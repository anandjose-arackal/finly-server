class TravelRequestsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def index
    @result = TravelRequests::Index.(current_user, params)
    respond
  end

  def show
    @result = TravelRequests::Show.(current_user, params)
    respond
  end



  def create
    @result = TravelRequests::Create.(current_user, params)
    respond
  end

  def update
    @result = TravelRequests::Update.(current_user, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages
    end
  end



  def booking_types
    @booking_types = BookingType.all
    respond_to do |format|
      format.json {}
    end
  end

end
