class Settlement::SMoneyRequests::Processing::MarkAsPaid < Settlement::SMoneyRequests::Processing::Base
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
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end
  end

  def init
    groups_presenter = Settlement::SMoneyRequests::Processing::Index.(user, params)
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
    result = Settlement::SMoneyRequests::Processing::PostOperation.(self.money_request_processor, {marked_as_completed: true}, true)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def post_process
    add_message :success, 'Marked as Paid Successfully'
  end

end