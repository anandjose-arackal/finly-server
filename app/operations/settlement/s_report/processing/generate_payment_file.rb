class Settlement::SReport::Processing::GeneratePaymentFile < Settlement::SReport::Processing::Base
  attr_accessor :report_processor_group

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
    self.report_processor_group = groups_presenter.report_processor_groups.find_by_id(id)
  end

  def validate
    unless self.report_processor_group.present?
      add_message :error, 'Batch not found'
      return
    end
    unless ReportProcessorGroupStatus.ids_for([:pending, :scheduled, :processing, :partially_completed]).include?(self.report_processor_group.status_id)
      add_message :error, 'Payment file cannot be generated at this stage'
      return
    end
  end

  def process
    # Format as required by PaymentFiles::Generate
    payment_params = []
    self.report_processor_group.mappings.include_for_payment_file&.each do |mapping|
      payment_params << {email: mapping.user.email, mobile_number: mapping.user.mobile_number, amount: mapping.amount, bank_account: mapping.processor_accountable}
    end
    self.response = PaymentFiles::Formats::YesBank::Process.(user, payment_params)
  end

end