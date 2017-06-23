class Integrations::Quickbooks::Configuration::Update < Integrations::Quickbooks::Configuration::Base

  attr_accessor :company, :config_params, :qb_config

  def pre_validate
    if user.blank? || company.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.company = user.company
    self.qb_config = company.quickbooks_configuration
    self.config_params = quickbooks_configuration_params
  end

  def validate
    if qb_config.nil?
      add_message :error, "You have not connected to Quickbooks yet, try again after connecting"
    end
  end

  def process
    unless qb_config.update(config_params)
      add_message :error, config.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Quickbooks configuration updated"
  end

  private

  def quickbooks_configuration_params
    params.require(:quickbooks_config).permit(:reimbursable_account_id, :non_reimbursable_account_id, :transaction_date_field)
  end

end