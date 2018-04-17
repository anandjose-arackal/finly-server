class TravelRequests::Update < TravelRequests::Base
  attr_accessor :travel_requests

  def pre_validate
    if params[:travel_request_id].blank? && params[:id].blank?
      add_message :error, 'Travel Request not found'
      return
    end
  end

  def init
    travel_request_id = params[:id] || params[:travel_request_id]

    self.travel_requests = TravelRequests::Index.(user, params)&.travel_requests&.find_by(id: travel_request_id)
  end

  def validate
    if travel_request.blank?
      add_message :error, 'Travel Request not found'
    end

    self.travel_requests.each do |tr|
      unless tr.can_destroy?
        add_message :error, "Travel request can only be deleted once it's retracted or rejected."
        return
      end
    end
  end

  def pre_process
  end

  def process
    self.travel_requests.each do |tr|
      unless tr.destroy
        add_message :error, tr.errors.full_messages
      end
    end
  end

  def post_process
    add_message :success, 'Travel Request deleted'
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end
end