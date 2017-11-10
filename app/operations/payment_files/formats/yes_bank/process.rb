class PaymentFiles::Formats::YesBank::Process < PaymentFiles::Formats::BaseFormat

  def pre_validate
    super
    return if has_errors?
    unless user.company.payment_file_configuration&.payload&.dig(:customer_code).present?
      add_message :error, 'Custom code for Yes Bank has not been configured'
      return
    end
  end

  def process

  end

  class PaymentFiles::Formats::YesBank::Process::Exporter < Exporter

  end

end