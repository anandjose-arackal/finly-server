class Admin::Cards::AssignRequests::Base < Admin::Base
  attr_accessor :card_assign_requests

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params&.dig(:card_assign_request_id).blank? and params&.dig(:id).blank? and params&.dig(:card_assign_requests).blank?
      add_message :error, 'Card Assign Request not found'
    end
  end

  def init
    self.card_assign_requests = params&.dig(:card_assign_requests)
    return unless self.card_assign_requests.blank?
    assign_requests_presenter = Admin::Cards::AssignRequests::Index.(user, params)
    unless assign_requests_presenter.success?
      add_message :error, assign_requests_presenter.messages[:error]
      return
    end
    id = (params[:id] or params[:card_assign_request_id])
    if id.present?
      id = id.split(',')
    end
    self.card_assign_requests = assign_requests_presenter.card_assign_requests.with_id(id)
  end

  def validate
    if self.card_assign_requests.blank?
      add_message :error, 'Card Assign Request not found'
    end
  end

end