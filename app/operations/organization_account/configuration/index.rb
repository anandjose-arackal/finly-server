class OrganizationAccount::Configuration::Index < OrganizationAccount::Configuration::Base

  attr_accessor :enforce_policy

  def process
    self.enforce_policy = user.company.enforce_policy_enabled? rescue nil
  end

  def success
    params[:enforce_policy]  = enforce_policy
    OrganizationAccount::Configuration::Index::IndexPresenter.new(user, params, messages)
  end

  class OrganizationAccount::Configuration::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :enforce_policy

    def init
      self.enforce_policy = params[:enforce_policy]
    end

  end

end