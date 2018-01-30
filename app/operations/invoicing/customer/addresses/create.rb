class Invoicing::Customer::Addresses::Create < Invoicing::Customer::Addresses::Base

  attr_accessor :customer, :address, :customer_parameters

  def init
    id = params[:id] || params[:customer_id]
    self.customer = user.company.customers.find_by(id: id)
    self.customer_parameters = customer_params
  end

  def validate
    if self.customer.blank?
      add_message :error, "Customer not found"
    end
  end

  def process
    self.address = self.customer.addresses.build(self.customer_parameters)
    unless self.address.save
      add_message :error, self.address.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Address created!"
  end
end
