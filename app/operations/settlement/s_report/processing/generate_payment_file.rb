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

    if [ 164].include? user.company.id # Satin CreditCare or L&C
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
    first_report = mapping&.reports&.first
    ifsc = mapping.processor_accountable&.ifsc
    ifsc_prefix =( ifsc.present? ? ifsc[0..3].upcase : '')
    data[:beneficiary_account_name] = BankDetailsMaster.where(ifsc_prefix: ifsc_prefix)&.first&.name
    data[:beneficiary_account_number] = mapping.processor_accountable.account_number
    data[:receiving_user_name] = mapping.user.name
    data[:amount] = mapping.amount.value
    data[:payment_mode] = 'NEFT'
    data[:date] = Date.today
    data[:beneficiary_ifsc] = ifsc
    data[:ifsc] = mapping.processor_accountable.ifsc
    data[:email] = mapping.user.email
    data[:receiving_mobile_number] = mapping.user.mobile_number
    data[:note] = mapping.note
    data[:report_ids] = mapping&.reports&.collect(&:id)&.join(', ')
    data[:report_id] = mapping.try(:report_id)
    data[:report_amount] = mapping.reports.find_by(id: data[:report_id])&.total_amount
    data[:reimbursable_amount] = mapping.reports.find_by(id: data[:report_id])&.total_amount([:reimbursable])
    data[:employee_id] = mapping.user.profile.employee_id
    if [144].include? user.company.id # StanzaCare or L&C
      data[:description] = retrieve_description(first_report)
      data[:approved_by] = retrieve_approved_by(first_report)
      data[:department] = retrieve_department(first_report)
      data[:period] = retrieve_period(first_report)
    end
    data
  end

  def retrieve_period(report)
    min = report&.expenses&.pluck(:date).min
    max = report&.expenses&.pluck(:date).max
    (min.month != max.month ? "#{min.strftime("%B %Y")} to #{max.strftime("%B %Y")}" : min.strftime("%B %Y"))
  end

  def retrieve_description(report)
    report&.expenses&.first&.category&.name
  end

  def retrieve_approved_by(report)
    return '' if report&.dlrms.blank?
    dlrm = report.dlrms.where(action_id: TrailAction.id_for(:approve)).first
    if dlrm&.taken_control_by_id&.present?
      return dlrm.taken_control_by&.name
    elsif dlrm&.forwarded_by_id&.present?
      return dlrm&.forwarded_by&.name
    elsif dlrm&.reviewer_id.present?
      return dlrm.reviewer&.name
    end
    ''
  end

  def retrieve_department(report)
    report&.expenses&.first&.custom_fields&.map { |cf| cf.configured_field_value if cf.field_key == 'department' }&.first
  end

end