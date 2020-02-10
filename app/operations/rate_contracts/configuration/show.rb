class RateContracts::Configuration::Show < RateContracts::Base
  attr_accessor :renewal_alert_period, :field_configurations

  def init
    self.renewal_alert_period = Period.all
    self.field_configurations = user.company.field_configurations.with_parent_type(FieldParentType.id_for(:rate_contract))
  end

  class RateContracts::Configuration::Show::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :renewal_alert_period, :field_configurations

    def init
      self.renewal_alert_period = params[:renewal_alert_period]
      self.field_configurations = params[:field_configurations]
    end
  end

  def success
    params[:renewal_alert_period] = renewal_alert_period
    params[:field_configurations] = self.field_configurations
    RateContracts::Configuration::Show::ConfigPresenter.new(user, params)
  end
end