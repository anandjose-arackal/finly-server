class Invoicing::Customer::Base < BaseOperation

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def validate

  end

  def customer_parameters
    params.require(:customer).permit(:name, :email, :mobile_number, :description, :gst, :pan,
                                     addresses_attributes: [:line_1, :line_2, :city, :state_id, :name, :pin_code, :id, :default])
  end

end