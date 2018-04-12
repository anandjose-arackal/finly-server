class Settlement::SReport::Processing::Cancel < Settlement::SReport::Processing::Base
  attr_accessor :report_group_processor

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:report_processor_group_id).present?
      add_message :error, 'Batch not found'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end
  end

  def init
    groups_presenter = Settlement::SReport::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    self.report_group_processor = groups_presenter.report_processor_groups.find_by_id(params[:report_processor_group_id])
  end

  def validate
    unless report_group_processor.present?
      add_message :error, 'Batch not found'
      return
    end
    unless ReportProcessorGroupStatus.ids_for([:pending, :scheduled, :failed, :partially_completed]).include?(self.report_group_processor.status_id)
      add_message :error, 'Batch cannot be cancelled at this stage'
      return
    end
    if self.report_group_processor.payment_order&.in_progress?
      add_message :error, 'Batch cannot be cancelled at this stage'
      return
    end
  end

  def process

    if self.report_group_processor.process_via_finly?
      payment_order = self.report_group_processor.payment_order
      if payment_order.present? and (payment_order.pending? or payment_order.scheduled? or payment_order.in_progress?)
        result = AccountManager::Payments::CancelPaymentOrder.(user, payment_order: payment_order)
        unless result.success?
          add_message :error, result.messages[:error]
          return
        end
      end
    end

    pending_mappings = self.report_group_processor.mappings.not_completed
    pending_mappings.update_all(status_id: ReportProcessorGroupStatus.id_for(:cancelled))

    pending_mappings_id = pending_mappings.pluck(:id)
    failed_reports = Report.with_processor_group_mapping(pending_mappings_id)
    failed_reports.update_all(report_processor_group_mapping_id: nil)

    if report_group_processor.partially_completed?
      self.report_group_processor.update(status_id: ReportProcessorGroupStatus.id_for(:completed))
    else
      self.report_group_processor.update(status_id: ReportProcessorGroupStatus.id_for(:cancelled))
    end
  end

  def post_process
    add_message :success, 'Cancelled Successfully'
  end

end