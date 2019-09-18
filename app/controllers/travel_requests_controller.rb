class TravelRequestsController < BaseControllers::WebBase


  def index
    @result = TravelRequests::Index.(current_user, params)
    respond
  end

  def show
    @result = TravelRequests::Show.(current_user, params)
    respond
  end

  def count
    @result = TravelRequests::Index.(current_user, params)
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

  def destroy
    @result = TravelRequests::Destroy.(current_user, params)
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

  def configuration
    @result = TravelRequests::Config::Show.(current_user, params)
    respond
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
      operation = TravelRequests::Review::Approve.new(current_user, params)
    when 2, '2'
      # i.e. submit
      operation = TravelRequests::Review::Submit.new(current_user, params)
    when 3, '3'
      # i.e. retract
      operation = TravelRequests::Review::Retract.new(current_user, params)
    when 4, '4'
      # i.e. reject
      operation = TravelRequests::Review::Reject.new(current_user, params)
    when 5, '5'
      # i.e. unapprove
      operation = TravelRequests::Review::Unapprove.new(current_user, params)
    when 6, '6'
      # i.e. take control
      operation = TravelRequests::Review::TakeControl.new(current_user, params)
    when 7, '7'
      # finish booking
      operation = TravelRequests::Review::FinishBooking.new(current_user, params)
    when 8, '8'
      operation = TravelRequests::Review::RetractBooking.new(current_user, params)
    when 9, '9'
      operation = TravelRequests::Review::RequestSelection.new(current_user, params)
    when 10, '10'
      operation = TravelRequests::Review::ConfirmSelection.new(current_user, params)
    when 11, '11'
      operation = TravelRequests::Review::ConfirmBooking.new(current_user, params)
    when 12, '12'
      operation = TravelRequests::Review::ApproveSelection.new(current_user, params)
    when 13, '13'
      operation = TravelRequests::Review::RejectSelection.new(current_user, params)
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
