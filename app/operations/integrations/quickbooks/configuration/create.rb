class Integrations::Quickbooks::Configuration::Create < Integrations::Quickbooks::Configuration::Base

  attr_accessor :company, :config_params

  def pre_validate
    if user.blank? || company.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.company = user.company
    self.config_params = quickbooks_configuration_params
  end

  def process
    config = company.build_quickbooks_configuration(config_params)
    unless config.save
      add_message :error, config.errors.full_messages
    end
  end

  private

  def quickbooks_configuration_params
    params.require(:quickbooks_config).permit(:reimbursable_account_id, :non_reimbursable_account_id, :transaction_date_field)
  end

end