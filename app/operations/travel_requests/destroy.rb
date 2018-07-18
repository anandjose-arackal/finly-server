class TravelRequests::Destroy < TravelRequests::Base
  attr_accessor :travel_requests

  def pre_validate
    if params[:travel_request_id].blank? && params[:id].blank?
      add_message :error, 'Travel Request not found'
      return
    end
  end

  def init
    travel_request_id = params[:id] || params[:travel_request_id]
    index_result = TravelRequests::Show.(user, params)
    unless index_result.success?
      add_message :error, index_result.messages[:error]
      return
    end
    self.travel_requests = index_result&.travel_requests&.with_id(travel_request_id)
  end

  def validate
    if travel_requests.blank?
      add_message :error, 'Travel Request not found'
    end

    self.travel_requests.each do |tr|
      unless tr.can_destroy?
        add_message :error, "Travel request with #{tr.id} can only be deleted once it's retracted or rejected."
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
        return
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