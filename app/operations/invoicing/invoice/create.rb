class Invoicing::Invoice::Create < Invoicing::Invoice::Base

  attr_accessor :invoice_params, :invoice, :customer

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    customer_id = params[:customer_id]
    self.customer = user.company.customers.find_by(id: customer_id)
  end

  def validate

  end

  def pre_process

  end

  def process
    self.invoice = user.company.outward_invoices.build(invoice_status_id: OutwardInvoiceStatus.id_for(:incomplete))
    if self.invoice.save
      if self.customer.present?
        # call the operation that assigns a particular invoice to a customer - ideally operation should success
        op = Invoicing::Invoice::Customer::Update.(user, {invoice_id: self.invoice.id, customer_id: self.customer.id})
        unless op.success?
          add_message :error, op.messages[:error]
          self.invoice.destroy
        end
      end
    else
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice successfully created!"
  end

  def success
    params[:invoice] = self.invoice
    Invoicing::Invoice::Base::InvoicePresenter.new(user, params, messages)
  end

end