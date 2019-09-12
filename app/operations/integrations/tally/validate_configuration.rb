class Integrations::Tally::ValidateConfiguration <  Integrations::Tally::Base
  attr_accessor :is_configured

  def authorized_user_types
    []
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    tally_configuration = user.company.tally_configuration
    self.is_configured = tally_configuration&.company_name.present?
  end

  def success
    params[:is_configured] = !!self.is_configured
    Integrations::Tally::ValidateConfiguration::Presenter.new(user, params)
  end

  class Integrations::Tally::ValidateConfiguration::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :is_configured

    def init
      self.is_configured = params[:is_configured]
    end
  end
end