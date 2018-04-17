class TravelRequests::Update < TravelRequests::Base
  attr_accessor :travel_request, :travel_request_parameters

  def init
    self.travel_request = TravelRequest.find(params[:id] || params[:travel_request_id])
    self.travel_request_parameters = travel_request_params
    debugger
  end

  def validate

  end

  def authorize
    policy_id = travel_request_params[:policy_id]
    if policy_id.present? and user.policies.with_id(policy_id).blank?
      add_message :error, 'User does not belong to the selected policy'
      raise_unauthorized_exception
    end
  end

  def process
    self.travel_request.assign_attributes(travel_request_parameters)
    if travel_request.valid?
      travel_request.save
      add_message :success, 'Successfully updated travel request'
    else
      add_message :error, self.travel_request.errors.full_messages
    end
  end
end
