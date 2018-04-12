class TravelRequests::Show < TravelRequests::Base
  attr_accessor :travel_request

  def init
    self.travel_request = TravelRequest.find(params[:id]) #todo Scope to company
  end

  def validate
    if travel_request.blank?
      add_message :error, 'Travel Request not found'
    end
  end

  def process
  end

  def success
    params[:travel_request] = self.travel_request
    TravelRequests::Show::ShowPresenter.new(user, params, messages)
  end

  class TravelRequests::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :travel_request, :destinations

    def init
      self.travel_request = params[:travel_request]
      self.destinations = travel_request.destinations
    end
  end

end