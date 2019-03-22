class Settlement::SMoneyRequests::Processing::GeneratePaymentFile < Settlement::SMoneyRequests::Processing::Base
  attr_accessor :money_request_processors, :group_mappings

  def authorized_user_types
    [:company_admin, :finance_manager]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:money_request_processor_id).blank? and params&.dig(:id).blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    groups_presenter = Settlement::SMoneyRequests::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    id = (params[:money_request_processor_id] or params[:id])
    self.money_request_processors = groups_presenter.money_request_processors.with_id(id)
    if self.money_request_processors.present?
      ids = self.money_request_processors.pluck(:id)
      self.group_mappings = MoneyRequestProcessorMapping.with_processor_id(ids)
    end
  end

  def validate
    unless self.group_mappings.present?
      add_message :error, 'Batch not found'
      return
    end
    unless (self.money_request_processors.pluck_status_id - MoneyRequestProcessorStatus.ids_for([:pending, :scheduled, :processing, :partially_completed])).blank?
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