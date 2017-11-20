class Settlement::SMoneyRequest::Processing::PostOperation < FinlyPostOperation
  attr_accessor :payment_order, :report_processor_group

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
        self.report_processor_group = ReportProcessorGroup.with_payment_order_id(self.payment_order.id)&.include_mapping_reports.first
      when ReportProcessorGroup
        self.report_processor_group = object
      else
        add_message :error, 'Error loading configuration'
        return
    end
  end

  def validate
    if self.report_processor_group.blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def process
    group_completed_status = ReportProcessorGroupStatus.id_for(:completed)
    group_failed_status = ReportProcessorGroupStatus.id_for(:failed)
    group_partially_complete_status = ReportProcessorGroupStatus.id_for(:partially_completed)
    report_status_settled = ReportStatus.id_for(:settled)

    has_success = false
    has_failure = false

    ReportProcessorGroupMapping.transaction do
      Report.transaction do
        ReportTrack.transaction do
          self.report_processor_group.mappings.each do |mapping|
            if mapping.payment.completed?
              has_success = true
              mapping.update(status_id: group_completed_status, completed_at: DateTime.now, marked_as_completed: !!params&.dig(:marked_as_completed))
              mapping.reports.update_all(controlling_user_id: nil, controlling_user_role_id: nil,
                                         controlling_for_user_id: nil, controlling_for_user_role_id: nil,
                                         status_id: report_status_settled, reimbursement: mapping.payment)
              mapping.reports.each do |report|
                report.tracks.create action_user_id: self.report_processor_group.created_by_user_id,
                                     action_user_role_id: self.report_processor_group.created_by_user_role_id,
                                     report_tracking_action_id: tracking_status,
                                     report_status_id: status,
                                     payment: self.payment
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
      self.report_processor_group.update(status_id: group_partially_complete_status, completed_at: DateTime.now, marked_as_completed: !!params&.dig(:marked_as_completed))
    elsif has_success
      self.report_processor_group.update(status_id: group_completed_status, completed_at: DateTime.now, marked_as_completed: !!params&.dig(:marked_as_completed))
    elsif has_failure
      self.report_processor_group.update(status_id: group_failed_status)
    end
  end

end