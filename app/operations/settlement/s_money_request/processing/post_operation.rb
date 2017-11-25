class Settlement::SMoneyRequest::Processing::PostOperation < FinlyPostOperation
  attr_accessor :payment_order, :money_request_processor_group

  def pre_validate
    if object.blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    case object.class.name
      when PaymentOrder.name
        self.payment_order = object
        self.money_request_processor_group = MoneyRequestProcessor.with_payment_order_id(self.payment_order.id)&.include_mapping_money_requests.first
      when MoneyRequestProcessor.name
        self.money_request_processor_group = object
      else
        add_message :error, 'Error loading configuration'
        return
    end
  end

  def validate
    if self.money_request_processor_group.blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def process
    group_completed_status = MoneyRequestProcessorStatus.id_for(:completed)
    group_failed_status = MoneyRequestProcessorStatus.id_for(:failed)
    group_partially_complete_status = MoneyRequestProcessorStatus.id_for(:partially_completed)
    money_request_status_settled = MoneyRequestStatus.id_for(:credited)

    has_success = false
    has_failure = false

    marked_as_completed = !!params&.dig(:marked_as_completed)

    MoneyRequestProcessorMapping.transaction do
      ::MoneyRequest.transaction do
        MoneyRequestTrack.transaction do
          self.money_request_processor_group.mappings.each do |mapping|
            if marked_as_completed or mapping.payment.completed?
              has_success = true
              mapping.update(status_id: group_completed_status, completed_at: DateTime.now, marked_as_completed: marked_as_completed)
              mapping.money_requests.update_all(controlling_user_id: nil, controlling_user_role_id: nil,
                                         controlling_for_user_id: nil, controlling_for_user_role_id: nil,
                                         status_id: money_request_status_settled, payment_id: mapping.payment&.id)
              mapping.money_requests.each do |money_request|
                money_request.tracks.create action_user_id: self.money_request_processor_group.created_by_user_id,
                                     action_user_role_id: self.money_request_processor_group.created_by_user_role_id,
                                     money_request_tracking_action_id: money_request_status_settled,
                                     status_id: status,
                                     payment: mapping.payment
              end
            elsif mapping.payment.failed?
              has_failure = true
              mapping.update(status_id: group_failed_status)
            end
          end
        end
      end
    end
    if has_success and has_failure
      self.money_request_processor_group.update(status_id: group_partially_complete_status, completed_at: DateTime.now, marked_as_completed: marked_as_completed)
    elsif has_success
      self.money_request_processor_group.update(status_id: group_completed_status, completed_at: DateTime.now, marked_as_completed: marked_as_completed)
    elsif has_failure
      self.money_request_processor_group.update(status_id: group_failed_status)
    end
  end

end