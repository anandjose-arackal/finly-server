class Card::AssignRequest::Index < Card::AssignRequest::Base
  attr_accessor :card_assign_requests

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    if user.company_admin?
      self.card_assign_requests = user.company.card_assign_requests
    end
  end

  def success
    params[:card_assign_requests] = self.card_assign_requests
    Card::AssignRequest::Index::SuccessPresenter.new(user, params, messages)
  end

  class Card::AssignRequest::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :card_assign_requests

    def init
      self.card_assign_requests = params[:card_assign_requests]
    end

  end

end