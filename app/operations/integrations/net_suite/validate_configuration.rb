class Integrations::NetSuite::ValidateConfiguration <  Integrations::NetSuite::Base
  attr_accessor :is_configured

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    net_suite_configuration = user.company.accounting_system_configuration
    self.is_configured = (net_suite_configuration&.accounting_system == 'net_suite')
    self.is_configured &&= net_suite_configuration&.enabled
    self.is_configured &&= net_suite_configuration&.options&.dig(:account).present?
  end

  def success
    params[:is_configured] = !!self.is_configured
    Integrations::NetSuite::ValidateConfiguration::Presenter.new(user, params)
  end

  class Integrations::NetSuite::ValidateConfiguration::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :is_configured

    def init
      self.is_configured = params[:is_configured]
    end

  end

end