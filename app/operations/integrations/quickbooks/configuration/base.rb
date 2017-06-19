class Integrations::Quickbooks::Configuration::Base < Integrations::Base

  def authorized_user_types
    [:company_admin]
  end
end