class Invoicing::Customer::Create < Invoicing::Customer::Base

  attr_accessor :customer, :customer_params, :company

  def init
    self.company = user.company
    self.customer_params = customer_parameters
  end

  def process
    self.customer = self.company.customers.build(self.customer_params)
    unless self.customer.save
      add_message :error, self.customer.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Customer successfully created"
  end

  private

  def customer_parameters
    params.require(:customer).permit(:name, :email, :mobile_number, :description)
  end
end