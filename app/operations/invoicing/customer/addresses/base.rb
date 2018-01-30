class Invoicing::Customer::Addresses::Base < Invoicing::Customer::Base

  def customer_params
    params.require(:customer).permit(:line_1, :line_2, :line_3, :city, :state_id, :name, :pin_code)
  end
end