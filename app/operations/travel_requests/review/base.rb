class TravelRequests::Review::Base < TravelRequests::Base
  attr_accessor :travel_request, :workflow_output

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
    validate_delegator_action if actual_current_user.present?
  end

  def init
    id = params[:id] || params[:travel_request_id]
    show_presenter = TravelRequests::Show.(user, params)
    unless show_presenter.success?
      add_message :error, show_presenter.messages[:error]
      return
    end
    self.travel_request = show_presenter.travel_request
  end

  def validate
    if travel_request.blank?
      add_message :error, "Travel Request not found"
      return
    end
  end

  def success
    params[:travel_request] = self.travel_request
    TravelRequests::Review::Base::RequestPresenter.new(user, params, messages)
  end

  class TravelRequests::Review::Base::RequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :travel_request

    def init
      self.travel_request  = params[:travel_request]
    end
  end
end