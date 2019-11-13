class PaymentFiles::Formats::CitiBank::ValidateConfig < BaseOperation

  attr_accessor :config, :options

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.config = (params[:config] or user.company.payment_file_configuration)
    self.options = (params[:options] or config.options)
  end

  def validate
    unless config.present?
      add_message :error, 'Payment File has not been configured correctly in the system'
      return
    end
  end

end