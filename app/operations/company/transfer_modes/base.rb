class Company::TransferModes::Base < Company::Base
  attr_accessor :transfer_mode, :transfer_mode_parameters, :company

  def pre_validate
    if params.blank? or params[:transfer_mode].blank?
      add_message :error, "Configuration parameters not sent"
      return
    end
  end

  def init
    self.company = user.company if params[:company_id].blank?
  end

  def mode_params
    params.require(:transfer_mode).permit(:mode_id)
  end
end