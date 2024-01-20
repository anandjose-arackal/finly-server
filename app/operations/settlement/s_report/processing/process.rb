class Settlement::SReport::Processing::Process < BackgroundOperation
  sidekiq_options queue: :payments
  attr_accessor :report_processor_group

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless params&.dig(:report_processor_group_id).present?
      add_message :error, 'Batch not found'
      return
    end
  end

  def init
    self.report_processor_group = ReportProcessorGroup.find_by_id(params&.dig(:report_processor_group_id))
  end

  def validate
    unless self.report_processor_group.present?
      add_message :error, 'Batch not found'
      return
    end
    unless ReportProcessorGroupStatus.ids_for([:pending, :scheduled, :failed, :partially_completed]).include?(self.report_processor_group.status_id)
      add_message :error, 'This batch cannot be processed at the moment'
      return
    end
  end

  def pre_process
    self.report_processor_group.update(status_id: ReportProcessorGroupStatus.id_for(:processing))
  end

  def process
    initiating_user = self.report_processor_group.created_by_user
    mappings = self.report_processor_group.mappings.not_completed
    initiating_account = self.report_processor_group.source_account

    has_failure = false
    has_success = false
    status_completed = ReportProcessorGroupStatus.id_for(:completed)
    status_failed = ReportProcessorGroupStatus.id_for(:failed)
    status_partially_completed = ReportProcessorGroupStatus.id_for(:partially_completed)
    system_message_error = SystemMessageType.id_for(:error)
    report_status_settled = ReportStatus.id_for(:settled)

    role = nil
    if user.admin? and admin_view?
      role = UserRole.admin_id
    elsif user.finance_manager? and finance_view?
      role = UserRole.finance_manager_id
    end

    mappings.each do |mapping|
      mapping.system_messages.destroy_all
      receiving_account = mapping.processor_accountable

      payment_request = PaymentRequest.(initiating_user, initiating_account, receiving_account&.class&.name, :credit, :reimbursement)
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
      mapping.reports.update_all(report_status_id: report_status_settled, reimbursement: payment)
      mapping.update(status_id: status_completed, payment: payment, completed_at: DateTime.now)
      mapping.reports.each do |report|
        Reports::MarkAsSettled.(user, {payment: payment, report: report, role_id: role, view: params[:view]})
      end

    end
    if has_success and has_failure
      self.report_processor_group.update(status_id: status_partially_completed)
    elsif has_success
      self.report_processor_group.update(status_id: status_completed)
    elsif has_failure
      self.report_processor_group.update(status_id: status_failed)
    end
  end

end