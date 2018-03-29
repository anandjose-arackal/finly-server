class Invoicing::Customer::Destroy < Invoicing::Customer::Base

  attr_accessor :customer

  def init
    id = params[:id] || params[:customer_id]
    self.customer = user.company.customers.find_by(id: id)
  end

  def process
    unless self.customer.update(active: false)
      add_message :error, self.customer.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Customer destroyed"
  end
end