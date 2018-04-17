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

  def review
    review_handler(params[:type])
  end

  def booking_types
    @booking_types = BookingType.all
    respond_to do |format|
      format.json {}
    end
  end

  private

  def review_handler(type)
    # unless type.present?
    #   respond response: :failure, message: "Invalid request"
    #   return
    # end
    operation = nil
    case type
      when 1, '1'
        # i.e. approve
        operation = TravelRequest::Review::Approve.new(current_user, params)
      when 2, '2'
        # i.e. submit
        operation = TravelRequest::Review::Submit.new(current_user, params)
      when 3, '3'
        # i.e. retract
        operation = TravelRequest::Review::Retract.new(current_user, params)
      when 4, '4'
        # i.e. reject
        operation = TravelRequest::Review::Reject.new(current_user, params)
      when 5, '5'
        # i.e. unapprove
        operation = TravelRequest::Review::Unapprove.new(current_user, params)
      when 6, '6'
        # i.e. take control
        operation = TravelRequest::Review::TakeControl.new(current_user, params)
      when 7, '7'
        # approve and forward
        operation = TravelRequest::Review::FinishBooking.new(current_user, params)
      else
        # do nothing?
    end
    if operation.blank?
      respond response: :failure, message: "Invalid update type"
      return
    end
    @result = operation.run
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error] || 'Error while updating details'
    end
  end

end
