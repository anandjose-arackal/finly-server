class Company::TransferModes::Destroy < Company::TransferModes::Base

  attr_accessor :transfer_mode

  def init
    transfer_mode_id = params[:id] || params[:mode_id] || params[:transfer_mode_id]
    self.transfer_mode = user.company.transfer_modes.find_by mode_id: transfer_mode_id
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.transfer_mode.blank?
      add_message :error, "Transfer Mode not found."
      return
    end

    if TransferMode.common_modes.include? self.transfer_mode.mode_id
      add_message :error, "This is a common transfer mode, which cannot be unset"
      return
    end
  end


  def process
    if self.transfer_mode.destroy
      add_message :success, 'Successfully Removed Transfer Mode'
    else
      add_message :error, self.transfer_mode.errors.full_messages
    end
  end
end