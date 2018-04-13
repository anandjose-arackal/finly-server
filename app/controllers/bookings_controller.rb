class BookingsController < ApplicationController

  before_action -> { finly_authorize! :web}

  def create
    @result = TravelRequests::Bookings::Create.(current_user, params)
    respond
  end

  def update
    @result = TravelRequests::Bookings::Update.(current_user, params)
    respond
  end

  def destroy
    @result = TravelRequests::Bookings::Update.(current_user, params)
    respond
  end

  def upload_attachment
    @result = TravelRequests::Bookings::UploadAttachment.(current_user, params)
    respond
  end
end