# This settles all money requests explicitly even when no details are supplied
# 
class Settlement::SMoneyRequests::Processing::MarkAsPaid < Settlement::SMoneyRequests::Processing::Base
  attr_accessor :money_request_processor, :pending_mappings, :completed_mappings

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

  def pre_process
    self.pending_mappings = self.money_request_processor.mappings.not_completed
    self.completed_mappings = self.money_request_processor.mappings.completed
  end

  def process
    if self.pending_mappings.blank?
      update_batch
      update_mapping_data
      return true
    end

    result = Settlement::SMoneyRequests::Processing::PostOperation.(self.money_request_processor, {marked_as_completed: true}, true)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

  def post_process
    add_message :success, 'Marked as Paid Successfully'
  end

  private

  def update_batch
    completed_status = MoneyRequestProcessorStatus.id_for(:completed)

    if self.money_request_processor.processed_amount.blank?
      processed_amount = Amount.new(currency_id: Currency.id_for(:INR))
    else
      processed_amount = self.money_request_processor.processed_amount
    end
    processed_amount.value = self.money_request_processor.payment_order&.amount_processed&.value || self.money_request_processor.total_amount&.value

    self.money_request_processor.update(status_id: completed_status, completed_at: DateTime.now,
                                          marked_as_completed: true,processed_amount: processed_amount)
  end

  def update_mapping_data
    request_status = MoneyRequestStatus.id_for(:credited)
    request_tracking_status = MoneyRequestTrackingAction.id_for(:credited)

    self.completed_mappings.each do |mapping|
      money_request_ids = []
      mapping.money_requests.where.not(status_id: MoneyRequestStatus.id_for(:credited)).each do |money_request|
        # explicitly settle money request when called from batch level
        money_request_ids << money_request.id
        money_request.tracks.create action_user_id: self.money_request_processor.created_by_user_id,
                                    action_user_role_id: self.money_request_processor.created_by_user_role_id,
                                    money_request_tracking_action_id: request_tracking_status,
                                    status_id: request_status,
                                    payment: mapping.payment
      end

      mapping.money_requests.where(id: money_request_ids).update_all(controlling_user_id: nil, controlling_user_role_id: nil,
                                                                     controlling_for_user_id: nil, controlling_for_user_role_id: nil,
                                                                     status_id: request_status, payment_id: mapping.payment&.id)
    end
  end

end