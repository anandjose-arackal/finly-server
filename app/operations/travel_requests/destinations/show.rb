class TravelRequests::Destinations::Show < TravelRequests::Base
  attr_accessor :travel_request, :destination

  def pre_validate
    return unless user_present? and params_present?
    if params[:travel_request_id].blank?
      add_message :error, 'Travel request not found'
      return
    end
    if params[:id].blank?
      add_message :error, 'Destination not found'
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
    self.destination = self.travel_request.destinations.with_id(params[:id])&.first
  end

  def validate
    unless self.destination.present?
      add_message :error, 'Destination not found'
      return
    end
  end

  def success
    params[:travel_request] = self.travel_request
    params[:destination] = self.destination
    TravelRequests::Destinations::Show::SuccessPresenter.new(user, params, messages)
  end

  class TravelRequests::Destinations::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :travel_request, :destination

    def init
      self.travel_request = params[:travel_request]
      self.destination = params[:destination]
    end

  end

end