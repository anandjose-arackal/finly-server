class Settlement::SMoneyRequest::Completed::Index < Settlement::SMoneyRequest::Completed::Base
  attr_accessor :money_requests

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    money_requests_presenter = ::MoneyRequest::Index.(user, params)
    unless money_requests_presenter.success?
      add_message :error, money_requests_presenter.messages[:error]
      return
    end
    self.money_requests = money_requests_presenter.money_requests.credited
  end

  def success
    params[:money_requests] = self.money_requests
    Settlement::SMoneyRequest::Pending::Index::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SMoneyRequest::Pending::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_requests, :paginated_money_requests

    def init
      self.money_requests = params[:money_requests]
      per_page = params[:per_page] || 30
      self.paginated_money_requests = self.money_requests.paginate(page: params[:page], per_page: per_page)
    end
  end


end