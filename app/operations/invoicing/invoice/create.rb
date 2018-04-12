class Invoicing::Invoice::Create < Invoicing::Invoice::Base

  attr_accessor :invoice_params, :invoice, :customer, :invoice_number, :payment_term, :invoice_date, :invoice_due_date, :invoice_type_id

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    customer_id = params[:customer_id]
    self.customer = user.company.customers.find_by(id: customer_id)

    # get default payment term for the company if any
    self.payment_term = user.company.payment_terms.where(default: true).first
    self.invoice_type_id = OutwardInvoiceType.id_for(params[:invoice_type]) || OutwardInvoiceType.id_for(:tax_invoice)
  end

  def validate

  end

  def pre_process
    self.invoice_date = Date.today
    calculate_due_date
  end

  def process
    # Assign default payment term as well
    self.invoice = user.company.outward_invoices.build(invoice_status_id: OutwardInvoiceStatus.id_for(:incomplete),
                                                       is_deleted: true, payment_term: payment_term,
                                                       date: invoice_date, due_date: invoice_due_date,
                                                       user_id: user.id, outward_invoice_type_id: invoice_type_id)
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

  def calculate_due_date
    if self.payment_term
      if self.payment_term.days_after
        self.invoice_due_date = self.invoice_date + payment_term.days_after.days
      elsif payment_term.name == "15 MFI" || payment_term.name == "21 MFI"
        day = payment_term.name.to_i
        date_next_month = invoice_date.next_month
        self.invoice_due_date = Date.new(date_next_month.year, date_next_month.month, day)
      elsif payment_term.name == "EOM"
        self.invoice_due_date = invoice_date.end_of_month
      end
    end
  end
end