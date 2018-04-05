class Invoicing::Company::FundsAutoTransferConfig::Update < Invoicing::Company::FundsAutoTransferConfig::Base
  attr_accessor :company, :auto_transfer_config, :auto_transfer_config_parameters

  def init
    self.company = user.company
    self.auto_transfer_config_parameters = auto_transfer_config_params
    self.auto_transfer_config = user.company&.collect_auto_transfer_config
  end

  def pre_validate
    if params[:password].blank?
      add_message :error, 'You need to provide your password update the configuration'
      return
    end

    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end
  end

  def validate
  end

  def process
    if auto_transfer_config
      self.auto_transfer_config.assign_attributes(auto_transfer_config_parameters)
    else
      self.auto_transfer_config = CompanyFundsAutoTransferConfig.new(auto_transfer_config_parameters)
      self.auto_transfer_config.company = company
    end

    if auto_transfer_config.save
      add_message :success, "Transfer Schedule Updated"
    end
  end

end
