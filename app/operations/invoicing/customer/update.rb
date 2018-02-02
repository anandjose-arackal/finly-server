class Invoicing::Customer::Update < Invoicing::Customer::Base

  attr_accessor :customer_attributes, :customer

  def init
    self.customer_attributes = customer_parameters
    id = params[:customer_id] || params[:id]
    self.customer = user.company.customers.find_by(id: id)
  end

  def validate

  end

  def pre_process
    # in case the ids for a particular customer need to be destroyed

  end

  def process
    unless self.customer.update(self.customer_attributes)
      add_message :error, self.customer.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Customer updated"
  end
end