class Invoicing::Customer::Base < BaseOperation

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def customer_parameters
    params.require(:customer).permit(:name, :email, :mobile_number, :description, :gst, :pan, :create_virtual_account,
                                     addresses_attributes: [:line_1, :line_2, :city, :state_id, :name, :pin_code, :id, :default, :address_name],
                                     virtual_bank_accounts_attributes: [:default_account, :name],
                                     customer_attachments_attributes: [:attached_file, :note])
  end

end