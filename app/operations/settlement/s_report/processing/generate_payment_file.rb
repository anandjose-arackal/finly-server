class Settlement::SReport::Processing::GeneratePaymentFile < Settlement::SReport::Processing::Base
  attr_accessor :report_processor_group, :group_mappings

  def authorized_user_types
    [:company_admin, :finance_manager, :vendor_payments_creditor]
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
    self.report_processor_group = groups_presenter.report_processor_groups.with_id(id)&.first
    self.group_mappings = self.report_processor_group&.mappings
  end

  def validate
    unless self.group_mappings.present?
      add_message :error, 'Batch not found'
      return
    end
    unless ReportProcessorGroupStatus.ids_for([:pending, :scheduled, :processing, :partially_completed]).include?(self.report_processor_group.status_id)
      add_message :error, 'Payment file cannot be generated for the selected batches'
      return
    end
  end

  def process
    # Format as required by PaymentFiles::Generate
    payment_params = []
    self.group_mappings.include_for_payment_file&.each do |mapping|
      payment_params << {
          beneficiary_account_name: mapping.processor_accountable.name,
          beneficiary_account_number: mapping.processor_accountable.account_number,
          receiving_user_name: mapping.user.name,
          amount: mapping.amount.value,
          payment_mode: 'NEFT',
          date: Date.today,
          beneficiary_ifsc: mapping.processor_accountable.ifsc,
          ifsc: mapping.processor_accountable.ifsc,
          email: mapping.user.email,
          receiving_mobile_number: mapping.user.mobile_number,
          note: mapping.note,
      }
    end
    self.response = PaymentFiles::Generate.(user, payment_file: payment_params, resources: self.group_mappings)
  end

end