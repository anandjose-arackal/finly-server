class Invoicing::Customer::Addresses::Base < Invoicing::Customer::Base

  def address_params
    params.require(:address).permit(:line_1, :line_2, :line_3, :city, :state_id, :name, :pin_code, :address_name, :landmark)
  end
end
