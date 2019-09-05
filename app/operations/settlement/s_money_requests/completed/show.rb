class Settlement::SMoneyRequests::Completed::Show < Settlement::SMoneyRequests::Completed::Base
  attr_accessor :money_request_processor

  def pre_validate
    if params[:id].blank?
      add_message :error, "Details for the advance not sent."
      return
    end
  end

  def init
    request_id = params[:id] || params[:money_request_id] || params[:money_request_processor_id]
    self.money_request_processor = current_company.money_request_processors.completed&.find_by(id: request_id)
    if finance_view?
      self.money_request_processor = self.money_request_processors.created_by_user(user.id)&.find_by(id: request_id)
    end
  end

  def validate
    if self.money_request_processor.blank?
      add_message :error, "Details for the advance not found."
      return
    end
  end

  def pre_process

  end

  def process

  end

  def success
    params[:money_request_processor] = self.money_request_processor
    Settlement::SMoneyRequests::Completed::Show::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SMoneyRequests::Completed::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :money_request_processor, :paginated_mappings, :mappings

    def init
      self.money_request_processor = params[:money_request_processor]

      self.mappings = self.money_request_processor.mappings
      per_page = params[:per_page] || 30
      self.paginated_mappings = self.mappings.paginate(page: params[:page], per_page: per_page)
    end

  end

end

