class Company::TransferModes::Create < Company::TransferModes::Base
  attr_accessor :transfer_mode_id

  def init
    super
    self.transfer_mode_id = params[:id] || params[:mode_id] || params[:transfer_mode_id]
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    mode = self.company.transfer_modes.find_by mode_id: self.transfer_mode_id
    if mode.present?
      add_message :error, "Transfer Mode already configured."
      return
    end

    if TransferMode.pluck(:id).exclude? self.transfer_mode_id.to_i
      add_message :error, "Unknown transfer mode"
      return
    end
  end

  def process
    self.transfer_mode = self.company.transfer_modes.build(mode_id: self.transfer_mode_id)

    if self.transfer_mode.save
      add_message :success, "Successfully configured a new Transfer Mode"
    else
      add_message :error, self.transfer_mode.errors.full_messages
    end
  end

end