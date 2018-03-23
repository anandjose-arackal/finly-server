class Invoicing::Company::FundsAutoTransferConfig::Base < Invoicing::Company::Base

  def auto_transfer_config_params
    params.require(:company_funds_auto_transfer_config).permit(:enabled, :days, :frequency_name, :frequency_day, :amount_transfer_type,
                                                               :transfer_mode,
                                                               threshold_amount_attributes: [:currency_id, :value])

  end
end