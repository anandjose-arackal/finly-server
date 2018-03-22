class Invoicing::Company::FundsAutoTransferConfig::Show < Invoicing::Company::FundsAutoTransferConfig::Base
  attr_accessor :company, :auto_transfer_config, :auto_transfer_config_parameters

  class Invoicing::Company::FundsAutoTransferConfig::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :auto_transfer_config

    def init
      self.auto_transfer_config = params[:auto_transfer_config]
    end
  end

  def init
    self.company = user.company
    self.auto_transfer_config_parameters = auto_transfer_config_params
    self.auto_transfer_config = user.company&.collect_auto_transfer_config
  end

  def validate
  end

  def process
    if auto_transfer_config
      self.auto_transfer_config.assign_attributes(auto_transfer_config_parameters)
    else
      self.auto_transfer_config = company.collect_auto_transfer_config.new(auto_transfer_config_parameters)
    end

    if auto_transfer_config.save
      add_message :success, ""
    end


  end

  def success
    params[:auto_transfer_config] = self.auto_transfer_config
    Invoicing::Company::FundsAutoTransferConfig::Show::ShowPresenter.new(user, params, messages)
  end
end
