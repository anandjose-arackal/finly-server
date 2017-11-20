class Settlement::SMoneyRequest::Processing::MarkAsPaid < Settlement::SMoneyRequest::Processing::Base
  attr_accessor :money_request_processor

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:money_request_processor_id).present?
      add_message :error, 'Batch not found'
      return
    end
  end

  def init
    groups_presenter = Settlement::SMoneyRequest::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    self.money_request_processor = groups_presenter.money_request_processors.find_by_id(params[:money_request_processor_id])
  end

  def validate
    unless money_request_processor.present?
      add_message :error, 'Batch not found'
      return
    end
    unless MoneyRequestProcessorStatus.ids_for([:pending, :scheduled, :failed, :partially_completed]).include?(self.money_request_processor.status_id)
      add_message :error, 'Batch cannot be Marked as Paid at this stage'
      return
    end
  end

  def process
    Settlement::SMoneyRequest::Processing::PostOperation.(self.money_request_processor, {marked_as_completed: true}, true)
  end

end