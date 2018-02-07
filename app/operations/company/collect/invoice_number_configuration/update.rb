# this operation updates the configuration for the invoice number sequence

class Company::Collect::InvoiceNumberConfiguration::Update < Company::Base

  attr_accessor :config, :config_params

  def init
    self.config = user.company.invoice_number_config
    self.config_params = invoice_number_configuration_params
  end

  def validate
    if self.config.blank?
      add_message :error, "Invoice number configuration not found"
    end
  end

  def process
    unless self.config.update(self.config_params)
      add_message :error, self.config.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Configuration updated"
  end

  private

  def invoice_number_configuration_params
    params.require(:invoice_number_config).permit(:prefix, :sequence_start)
  end

end