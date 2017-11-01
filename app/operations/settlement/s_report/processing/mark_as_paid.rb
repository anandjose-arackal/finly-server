class Settlement::SReport::Processing::MarkAsPaid < Settlement::SReport::Processing::Base

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
  end

  def init
    groups_presenter = Settlement::SReport::Processing::Index.(user, params)
    unless report_group_processors_presenter.success?
      add_message :error, report_group_processors_presenter.messages[:error]
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
      add_message :error, 'Batch cannot be Marked as Paid at this stage'
      return
    end
  end

  def process
    pending_mappings = self.report_group_processor.mappings.pending
    completed_status = ReportProcessorGroupStatus.id_for(:completed)
    pending_mappings.update_all(status_id: completed_status, completed_at: DateTime.now, marked_as_completed: true)
    self.report_group_processor.update(status_id: completed_status, completed_at: DateTime.now, marked_as_completed: true)
  end

end