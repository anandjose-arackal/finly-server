class TravelRequests::Destinations::Create < TravelRequests::Base
  attr_accessor :destination, :travel_request

  def pre_validate
    return unless user_present? and params_present?
    unless params[:travel_request_id].present?
      add_message :error, 'Travel request not found'
      return
    end
  end

  def init
    travel_request_presenter = TravelRequests::Show.(user, id: (params[:travel_request_id]), view: params[:view])
    unless travel_request_presenter.success?
      add_message :error, travel_request_presenter.messages[:error]
      return
    end
    self.travel_request = travel_request_presenter.travel_request
    self.destination = self.travel_request.destinations.build strong_params
  end

  def validate
    unless self.destination.valid?
      add_message :error, self.destination.errors.full_messages
      return
    end
  end

  def process
    self.destination.save
  end

  protected

  def strong_params
    params.require(:destination).permit(:name, :map_id)
  end

end