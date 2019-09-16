class Integration::NetSuiteController < BaseControllers::WebBase

  set_tokens_in_header :invoices

  def invoices
    @result = Integrations::NetSuite::Invoices.(current_user, params)
    respond
  end

  def check
    @result = Integrations::NetSuite::ValidateConfiguration.(current_user, params)
    respond
  end

end
