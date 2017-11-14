class Settlement::SReport::Processing::GeneratePaymentFile < Settlement::SReport::Processing::Base
  attr_accessor :report_processor_groups, :group_mappings

  def authorized_user_types
    [:company_admin, :finance_manager]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:report_processor_group_id).blank? and params&.dig(:id).blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    groups_presenter = Settlement::SReport::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    id = (params[:report_processor_group_id] or params[:id])
    self.report_processor_groups = groups_presenter.report_processor_groups.with_id(id)
    if self.report_processor_groups.present?
      ids = self.report_processor_groups.pluck(:id)
      self.group_mappings = ReportProcessorGroupMapping.with_processor_group_id(ids)
    end
  end

  def validate
    unless self.group_mappings.present?
      add_message :error, 'Batch not found'
      return
    end
    unless (self.report_processor_groups.pluck_status_id - ReportProcessorGroupStatus.ids_for([:pending, :scheduled, :processing, :partially_completed])).blank?
      add_message :error, 'Payment file cannot be generated for the selected batches'
      return
    end
  end

  def process
    # Format as required by PaymentFiles::Generate
    payment_params = []
    self.group_mappings.include_for_payment_file&.each do |mapping|
      payment_params << {email: mapping.user.email, mobile_number: mapping.user.mobile_number, amount: mapping.amount, bank_account: mapping.processor_accountable}
    end
    self.response = PaymentFiles::Formats::YesBank::Process.(user, payment_params)
  end

end