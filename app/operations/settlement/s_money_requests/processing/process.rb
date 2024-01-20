class Settlement::SMoneyRequests::Processing::Process < BackgroundOperation
  sidekiq_options queue: :payments
  attr_accessor :money_request_processor

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless params&.dig(:money_request_processor_id).present?
      add_message :error, 'Batch not found'
      return
    end
  end

  def init
    self.money_request_processor = MoneyRequestProcessor.find_by_id(params&.dig(:money_request_processor_id))
  end

  def validate
    unless self.money_request_processor.present?
      add_message :error, 'Batch not found'
      return
    end
    unless MoneyRequestProcessorStatus.ids_for([:pending, :scheduled, :failed, :partially_completed]).include?(self.money_request_processor.status_id)
      add_message :error, 'This batch cannot be processed at the moment'
      return
    end
  end

  def pre_process
    self.money_request_processor.update(status_id: MoneyRequestProcessorStatus.id_for(:processing))
  end

  def process
    initiating_user = self.money_request_processor.created_by_user
    mappings = self.money_request_processor.mappings.not_completed
    initiating_account = self.money_request_processor.source_account

    has_failure = false
    has_success = false
    status_completed = MoneyRequestProcessorStatus.id_for(:completed)
    status_failed = MoneyRequestProcessorStatus.id_for(:failed)
    status_partially_completed = MoneyRequestProcessorStatus.id_for(:partially_completed)
    system_message_error = SystemMessageType.id_for(:error)
    money_request_status_settled = MoneyRequestStatus.id_for(:credited)

    role = nil
    if user.admin? and admin_view?
      role = UserRole.admin_id
    elsif user.finance_manager? and finance_view?
      role = UserRole.finance_manager_id
    end

    mappings.each do |mapping|
      mapping.system_messages.destroy_all
      receiving_account = mapping.processor_accountable

      payment_request = PaymentRequest.(initiating_user, initiating_account, receiving_account&.class&.name, :credit, :advance)
      payment_request.add_payment_item(PaymentRequest::PaymentItem.(mapping.user, receiving_account, mapping.amount&.value))

      # calling the payment processor to complete the transfer using adapters
      op = AccountManager::Payments::PaymentProcessor.(initiating_user, {payment_request: payment_request})
      unless op.success?
        has_failure = true
        system_messages = []
        op.messages[:error]&.each do |message|
          next if message.blank?
          system_messages << {
              content: message,
              system_message_type_id: system_message_error
          }
        end
        mapping.update(status_id: status_failed, system_messages_attributes: system_messages)
        next
      end
      has_success = true
      payment = op.payment_order.payments.first
      mapping.money_requests.update_all(status_id: money_request_status_settled, payment: payment)
      mapping.update(status_id: status_completed, payment: payment, completed_at: DateTime.now)
      mapping.money_requests.each do |money_request|
        ::MoneyRequests::MarkAsSettled.(user, {payment: payment, money_request: money_request, role_id: role, view: params[:view]})
      end

    end
    if has_success and has_failure
      self.money_request_processor.update(status_id: status_partially_completed)
    elsif has_success
      self.money_request_processor.update(status_id: status_completed)
    elsif has_failure
      self.money_request_processor.update(status_id: status_failed)
    end
  end

end