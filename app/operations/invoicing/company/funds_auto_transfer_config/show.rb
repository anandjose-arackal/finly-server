class Invoicing::Company::FundsAutoTransferConfig::Show < Invoicing::Company::FundsAutoTransferConfig::Base
  attr_accessor :auto_transfer_config

  class Invoicing::Company::FundsAutoTransferConfig::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :auto_transfer_config

    def init
      self.auto_transfer_config = params[:auto_transfer_config]
    end
  end

  def init
    self.auto_transfer_config = user.company&.collect_auto_transfer_config
  end

  def validate
  end

  def success
    params[:auto_transfer_config] = self.auto_transfer_config
    Invoicing::Company::FundsAutoTransferConfig::Show::ShowPresenter.new(user, params, messages)
  end
end
