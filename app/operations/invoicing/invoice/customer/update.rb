class Invoicing::Invoice::Customer::Update < Invoicing::Invoice::Base

  attr_accessor :invoice, :customer, :customer_params

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid request"
    end
  end

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find invoice_id
    # check if an existing customer is being associated, or a new customer is being added
    if params[:customer_id].present?
      customer_id = params[:customer_id]
      self.customer = user.company.customers.find_by(id: customer_id)
    else
      self.customer_params = customer_parameters
    end
  end

  def validate
    if self.customer.blank? && self.customer_params.blank?
      add_message :error, "Customer not found"
      return
    end

    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    unless self.invoice.editable?
      add_message :error, "Invoice cannot be changed in this state"
    end
  end

  def process
    if self.customer.present?
      # setting the shipping and billing address of this invoice as the default address of the customer
      default_address_id = nil
      address = self.customer.addresses.default.first || self.customer.addresses.first
      full_address = get_full_address(address)


      unless self.invoice.update(customer_id: self.customer.id, billing_address: full_address, shipping_address: full_address)
        add_message :error, self.invoice.errors.full_messages
        return
      end
    end
  end

  def post_process
    add_message :success, "Customer updated!"
  end


  private

  def customer_parameters
    params.require(:customer).permit(:name, :email, :mobile_number, :description, :gst, :pan,
                                     addresses_attributes: [:line_1, :line_2, :city, :state_id, :name, :pin_code, :id, :default])
  end

  def get_full_address(address)
    unless address
      return ""
    end
    address_text = ""
    address_text += address&.name.to_s + ",\n"
    address_text += address&.line_1.to_s + ",\n"
    address_text += address&.line_2.to_s + ",\n"
    address_text += address&.landmark.to_s + ",\n"
    address_text += address&.city.to_s + ",\n"
    address_text += address&.state&.name.to_s + ",\n"
    address_text += address&.pin_code.to_s
  end
end