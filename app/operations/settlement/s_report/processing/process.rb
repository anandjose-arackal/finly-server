class Settlement::SReport::Processing::Process < BackgroundOperation
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
    mappings = self.report_processor_group.mappings
    source_account = self.report_processor_group.source_account_type
    self.mappings.each do |mapping|

    end
  end

end