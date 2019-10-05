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

    if user.company.id == 164 # Satin CreditCare
      load_data = satin_data
    else
      load_data = general_data
    end

    load_data.each do |mapping|
      payment_params << data_points(mapping)
    end

    self.response = PaymentFiles::Generate.(user, payment_file: payment_params, resources: self.group_mappings)
  end

  private

  def general_data
    self.group_mappings.include_for_payment_file
  end

  def satin_data
    self.group_mappings.include_for_payment_file&.left_joins(:reports).select('report_processor_group_mappings.*, reports.id AS report_id')
  end

  def data_points(mapping)
    data = {}
    data[:beneficiary_account_name] = mapping.processor_accountable.name
    data[:beneficiary_account_number] = mapping.processor_accountable.account_number
    data[:receiving_user_name] = mapping.user.name
    data[:amount] = mapping.amount.value
    data[:payment_mode] = 'NEFT'
    data[:date] = Date.today
    data[:beneficiary_ifsc] = mapping.processor_accountable.ifsc
    data[:ifsc] = mapping.processor_accountable.ifsc
    data[:email] = mapping.user.email
    data[:receiving_mobile_number] = mapping.user.mobile_number
    data[:note] = mapping.note
    data[:report_ids] = mapping&.reports&.collect(&:id)&.join(', ')
    data[:report_id] = mapping.try(:report_id)
    data
  end

end