class Admin::Cards::AssignRequests::Base < Admin::Base
  attr_accessor :card_assign_request

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params&.dig(:card_assign_request_id).blank?
      add_message :error, 'Card Assign Request not found'
    end
  end

  def init
    assign_requests_presenter = Admin::Cards::AssignRequests::Index.(user, params)
    unless assign_requests_presenter.success?
      add_message :error, assign_requests_presenter.messages[:error]
      return
    end
    self.card_assign_request = assign_requests_presenter.card_assign_requests.find_by_id(params[:card_assign_request_id])
  end

  def validate
    if self.card_assign_request.blank?
      add_message :error, 'Card Assign Request not found'
    end
  end

end