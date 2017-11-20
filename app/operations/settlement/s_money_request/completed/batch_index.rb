class Settlement::SMoneyRequest::Completed::BatchIndex < Settlement::SMoneyRequest::Completed::Base
  attr_accessor :money_request_processors

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.money_request_processors = current_company.money_request_processors.completed
    if finance_view?
      self.money_request_processors = self.money_request_processors.created_by_user(user.id)
    end
  end

  def success
    params[:money_request_processors] = self.money_request_processors
    Settlement::SMoneyRequest::Completed::BatchIndex::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SMoneyRequest::Completed::BatchIndex::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_request_processors, :paginated_money_request_processors

    def init
      self.money_request_processors = params[:money_request_processors]
      per_page = params[:per_page] || 30
      self.paginated_money_request_processors = self.money_request_processors&.include_for_show.paginate(page: params[:page], per_page: per_page)
    end

  end


end