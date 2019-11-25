  class PaymentFiles::Generate < BaseOperation
  attr_accessor :file_format, :adapter, :payment_file_params

  def authorized_user_types
    [:vendor_payments_admin, :vendor_payments_reviewer, :vendor_payments_creditor, :vendor_payments_initiator, :auditor]
  end

  def pre_validate
    if current_company.blank?
      add_message :error, 'Company not found'
      return
    end
  end

  def init
    load_adapter
  end

  def validate
    unless self.adapter.present?
      add_message :error, 'Error loading payment file configuration'
      return
    end
  end

  def process
    self.response = self.adapter.(user, params)
  end

  protected

  def load_adapter
    file_format = current_company.payment_file_configuration&.file_format
    unless file_format.present?
      add_message :error, 'Payment File has not been configured for your company'
      return
    end
    self.adapter = PaymentFiles::Config.adapter_for(file_format)
  end

end