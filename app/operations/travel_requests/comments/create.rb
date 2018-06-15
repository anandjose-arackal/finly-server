class TravelRequest::Comments::Create < TravelRequest::Comments::Base

  attr_accessor :comment
  attr_accessor :travel_request, :booking_types

  def init
    def init
      self.travel_request = TravelRequest.find(params[:id]) #todo Scope to company
      self.booking_types = BookingType.all
    end
  end

  def validate
    if self.travel_request.blank?
      add_message :error, "Travel request not found"
    end
  end

  def process

  end
end