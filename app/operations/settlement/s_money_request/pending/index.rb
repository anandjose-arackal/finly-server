class Settlement::SMoneyRequest::Pending::Index < Settlement::SMoneyRequest::Pending::Base
  attr_accessor :money_requests

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    money_request_presenter = MoneyRequest::Index.(user, params)
    unless money_request_presenter.success?
      add_message :error, money_request_presenter.messages[:error]
      return
    end
    self.money_requests = money_request_presenter.money_requests.approved
  end

  def success
    params[:money_requests] = self.money_requests
    Settlement::SMoneyRequest::Pending::Index::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SMoneyRequest::Pending::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_requests

    def init
      self.money_requests = params[:money_requests]
    end
  end


end