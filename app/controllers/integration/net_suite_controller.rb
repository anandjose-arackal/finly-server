class Integration::NetSuiteController < BaseControllers::WebBase

  before_action :set_tokens_in_header, only: [:invoices]
  before_action -> { finly_authorize! :web }

  def invoices
    @result = Integrations::NetSuite::Invoices.(current_user, params)
    respond
  end

  def check
    @result = Integrations::NetSuite::ValidateConfiguration.(current_user, params)
    respond
  end

end
