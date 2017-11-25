class Settlement::SMoneyRequest::Processing::GeneratePaymentFile < Settlement::SMoneyRequest::Processing::Base
  attr_accessor :money_request_processors, :group_mappings

  def authorized_user_types
    [:company_admin, :finance_manager]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:money_request_processor_group_id).blank? and params&.dig(:id).blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    groups_presenter = Settlement::SMoneyRequest::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    id = (params[:money_request_processor_group_id] or params[:id])
    self.money_request_processors = groups_presenter.money_request_processors.with_id(id)
    if self.money_request_processors.present?
      ids = self.money_request_processors.pluck(:id)
      self.group_mappings = MoneyRequestProcessorGroupMapping.with_processor_group_id(ids)
    end
  end

  def validate
    unless self.group_mappings.present?
      add_message :error, 'Batch not found'
      return
    end
    unless (self.money_request_processors.pluck_status_id - MoneyRequestProcessorGroupStatus.ids_for([:pending, :scheduled, :processing, :partially_completed])).blank?
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