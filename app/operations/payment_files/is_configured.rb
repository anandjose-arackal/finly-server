class PaymentFiles::IsConfigured < BaseOperation
  attr_accessor :company

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.company = user.company
  end

  def validate
    unless self.company.present?
      add_message :error, 'Company not found'
      return
    end
    config = self.company.payment_file_configuration
    file_format = config&.file_format
    unless file_format.present?
      add_message :error, 'Payment file format has not yet been configured for your company'
      return
    end
    validator = PaymentFiles::Config.validator_for(file_format)
    if validator.present?
      result = validator.(user, config: config)
      unless result.success?
        add_message :error, (result&.messages[:error] || 'Unknown Error')
        return
      end
    end
  end

end