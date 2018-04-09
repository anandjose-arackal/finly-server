class TravelRequest::Create < TravelRequest::Base
  attr_accessor :travel_request, :travel_request_parameters

  def pre_validate
  end

  def init
    self.travel_request_parameters = travel_request_params

  end

  def validate

  end

  def process
    self.travel_request = TravelRequest.new(travel_request_parameters)
    if travel_request.save
      add_message :success, 'Successfully saved travel request'
    end
  end

end
