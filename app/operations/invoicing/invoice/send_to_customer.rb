class Invoicing::Invoice::SendToCustomer < Invoicing::Invoice::Base

  attr_accessor :invoice, :email_options

  def init
    id = params[:id] || params[:outward_invoice_ids] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find id

    unless self.invoice
      add_message :error, "Invoices not found"
      return
    end

    self.email_options = {}

    self.email_options[:email_to] = params[:email][:to] || invoice.email
    self.email_options[:email_bcc] = params[:email][:bcc]
    self.email_options[:email_subject] = params[:email][:subject] || "Invoice for #{self.invoice.customer.name} - #{self.invoice.invoice_number}"
    self.email_options[:email_body] = params[:email][:body] || ""

    if params[:invoice]
      attachment_ids = params[:invoice][:attachments] || []
    end

    self.email_options[:attachments] = invoice.attachments.with_id attachment_ids


  end

  def validate
    if invoice.incomplete?
      add_message :error, "Incomplete invoice cannot be sent to customers. The invoice is incomplete"
      return
    end


    if email_options[:email_to].blank?
      add_message :error, "The invoice doesn't have an email address associated with it."
    end

  end

  def process
    InvoiceMailer.delay.send_to_customer(invoice, email_options)
  end

  def post_process
    add_message :success, "Invoice successfully sent!"
  end

end