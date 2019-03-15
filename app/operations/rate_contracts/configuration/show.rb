class RateContracts::Configuration::Show < RateContracts::Base
  attr_accessor :renewal_alert_period

  def init
    self.renewal_alert_period = Period.all
  end

  class RateContracts::Configuration::Show::ConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :renewal_alert_period

    def init
      self.renewal_alert_period = params[:renewal_alert_period]
    end
  end

  def success
    params[:renewal_alert_period] = renewal_alert_period
    RateContracts::Configuration::Show::ConfigPresenter.new(user, params)
  end
end