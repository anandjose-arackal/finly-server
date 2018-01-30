class Invoicing::Customer::Addresses::Destroy < Invoicing::Customer::Base

  attr_accessor :customer, :address

  def init
    customer_id = params[:customer_id]
    self.customer = user.company.customers.find_by(id: customer_id)
    address_id = params[:id] || params[:address_id]
    self.address = self.customer&.addresses&.find_by(id: address_id)
  end

  def validate
    if self.customer.blank?
      add_message :error, "Customer not found"
      return
    end

    if self.address.blank?
      add_message :error, "Address not found"
      return
    end
  end

  def process
    unless self.address.destroy
      add_message :error, self.address.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Address deleted!"
  end

end