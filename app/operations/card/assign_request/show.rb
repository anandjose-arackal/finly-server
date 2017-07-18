class Card::AssignRequest::Show < Card::AssignRequest::Base
  attr_accessor :card_assign_request

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:id).blank? and params&.dig(:card_assign_request_id).blank?
      add_message :error, 'Card Assign Request not found'
      return
    end
  end

  def init
    request_index_presenter = Card::AssignRequest::Index.(user, params)
    unless request_index_presenter.success?
      add_message :error, request_index_presenter.messages[:error]
      return
    end
    id = (params[:id] or params[:card_assign_request_id])
    self.card_assign_request = request_index_presenter.card_assign_requests.find_by_id(id)
  end

  def success
    params[:card_assign_request] = self.card_assign_request
    Card::AssignRequest::Show::SuccessPresenter.new(user, params, messages)
  end

  class Card::AssignRequest::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :card_assign_request

    def init
      self.card_assign_request = params[:card_assign_request]
    end

  end

end