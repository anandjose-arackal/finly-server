class Settlement::SMoneyRequests::Completed::BatchIndex < Settlement::SMoneyRequests::Completed::Base
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
    Settlement::SMoneyRequests::Completed::BatchIndex::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SMoneyRequests::Completed::BatchIndex::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_request_processors, :paginated_money_request_processors

    has_scope :filter_search
    has_scope :filter_user_id
    has_scope :filter_created_by_user_id
    has_scope :filter_payment_type
    has_scope :filter_date
    has_scope :filter_scheduled_date
    has_scope :filter_completed_date

    def init
      self.money_request_processors = params[:money_request_processors]
      per_page = params[:per_page] || 30
      self.money_request_processors = apply_scopes(self.money_request_processors, params)
      self.paginated_money_request_processors = self.money_request_processors&.include_for_show.paginate(page: params[:page], per_page: per_page)
    end

  end


end