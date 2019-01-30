class PaymentFiles::SetConfiguration < PaymentFiles::Base
  attr_accessor :update_params, :payment_file_configuration

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params&.dig(:payment_file_configuration).present?
      add_message :error, 'Configuration cannot be blank'
      return
    end
  end

  def init
    self.update_params = strong_params
    return if self.update_params.blank?
    self.payment_file_configuration = user.company.payment_file_configuration
    if payment_file_configuration.nil?
      self.payment_file_configuration = user.company.build_payment_file_configuration(self.update_params)
    else
      self.payment_file_configuration.assign_attributes(self.update_params)
    end
  end

  def validate
    unless update_params.present?
      add_message :error, 'Configuration cannot be blank'
      return
    end
    unless self.payment_file_configuration.valid?
      add_message :error, self.payment_file_configuration.errors.full_messages
      return
    end
  end

  def process
    unless payment_file_configuration.save
      add_message :error, payment_file_configuration.errors.full_messages
      return
    end
  end

  protected
  def strong_params
    p = params.require(:payment_file_configuration).permit(:file_format)
    p[:options] = params&.dig(:payment_file_configuration, :options)
    p.permit!
  end

end