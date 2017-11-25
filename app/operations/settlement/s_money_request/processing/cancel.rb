class Settlement::SMoneyRequest::Processing::Cancel < Settlement::SMoneyRequest::Processing::Base
  attr_accessor :money_request_group_processor

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:money_request_processor_group_id).present?
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
    self.money_request_group_processor = groups_presenter.money_request_processors.find_by_id(params[:money_request_processor_group_id])
  end

  def validate
    unless money_request_group_processor.present?
      add_message :error, 'Batch not found'
      return
    end
    unless MoneyRequestProcessorGroupStatus.ids_for([:pending, :scheduled, :failed, :partially_completed]).include?(self.money_request_group_processor.status_id)
      add_message :error, 'Batch cannot be cancelled at this stage'
      return
    end
  end

  def process
    pending_mappings = self.money_request_group_processor.mappings.pending
    pending_mappings_id = pending_mappings.pluck(:id)
    MoneyRequest.with_processor_group_mapping(pending_mappings_id).update_all(money_request_processor_group_mapping_id: nil)
    pending_mappings.update_all(status_id: MoneyRequestProcessorGroupStatus.id_for(:cancelled))
    if money_request_group_processor.partially_completed?
      self.money_request_group_processor.update(status_id: MoneyRequestProcessorGroupStatus.id_for(:completed))
    else
      self.money_request_group_processor.update(status_id: MoneyRequestProcessorGroupStatus.id_for(:cancelled))
    end
  end

end