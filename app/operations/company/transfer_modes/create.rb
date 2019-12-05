class Company::TransferModes::Create < Company::TransferModes::Base


  def init
    super
    self.transfer_mode_parameters = mode_params
  end

  def validate
    mode = self.company.transfer_modes.find_by mode_id: transfer_mode_parameters[:mode_id]
    if mode.present?
      add_message :error, "Transfer Mode already configured."
      return
    end

    if TransferMode.pluck(:id).exclude? transfer_mode_parameters[:mode_id]
      add_message :error, "Unknown transfer mode"
      return
    end
  end

  def process
    self.transfer_mode = self.company.transfer_modes.build(transfer_mode_parameters)

    if self.transfer_mode.save
      add_message :success, "Successfully configured a new Transfer Mode"
    else
      add_message :error, self.transfer_mode.errors.full_messages
    end
  end

end