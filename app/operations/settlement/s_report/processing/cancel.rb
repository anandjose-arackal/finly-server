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
      add_message :error, 'Batch cannot be cancelled at this stage'
      return
    end
  end

  def process
    if report_group_processor.partially_completed?
      pending_mappings = self.report_group_processor.mappings.pending
      pending_mappings.each { |mapping| mapping.destroy }
      self.report_group_processor.update(status_id: ReportProcessorGroupStatus.id_for(:completed))
    else
      self.report_group_processor.destroy
    end
  end

end