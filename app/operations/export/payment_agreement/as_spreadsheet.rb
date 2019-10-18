class Export::PaymentAgreement::AsSpreadsheet < Export::PaymentAgreement::Base

  attr_accessor :headers, :contents, :general_invoice_items, :rental_invoices_items, :security_deposits_items, :beneficiary_payments_items

  def init
    self.headers ||= []
    self.contents ||= []
  end

  def process
    result_presenter = ::PaymentAgreements::Index.(user, params)
    unless result_presenter.success?
      add_message :error, result_presenter.messages[:error]
      return
    end

    self.headers = payment_agreement_headers + invoice_headers + security_deposit_headers

    payment_agreements = result_presenter.payment_agreements
    payment_agreements.each do |payment_agreement|
      general_invoice_item_ids = payment_agreement.general_invoices.joins(:invoice_items).pluck('invoice_line_items.id')
      self.general_invoice_items = InvoiceLineItem.where(id: general_invoice_item_ids)
      general_invoice_item_ids = payment_agreement.rental_invoices.joins(:invoice_items).pluck('invoice_line_items.id')
      self.rental_invoice_items = InvoiceLineItem.where(id: rental_invoice_item_ids)

      rental_invoices_item_ids = payment_agreement.rental_invoices.joins(:invoice_items).pluck('invoice_line_items.id')
      self.security_deposits_items = payment_agreement.security_deposits
      self.beneficiary_payments_items = payment_agreement.beneficiary_payments
    end

    self.contents += general_invoice_contents + rental_invoice_contents + security_deposit_contents + beneficiary_payment_contents

  end

  def post_process
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'payment_agreement'}, messages)
  end

  def payment_agreement_headers
    [
      "Agreement Number",
      "Agreement Type",
      "Title",
      "Policy",
      "Agreement Date",
      "Execution Date",
      "Expiration Date",
      "Renewal Date",
      "No Expiration",
      "Agreement Creation Date",
      "Rejection Note",
      "Renewal Reminder Date",
      "Remaining Amount",
      "Status",
      "Termination Reason",
      "Terminated At",
      "Agreement Creator Name",
      "Agreement Terminated By"
    ]
  end

  def invoice_headers
    [
      "Vendor Name",
      "Vendor Location",
      "Vendor Code",
      "Account Name",
      "Account Number",
      "Department",
      "Location",
      "Cost Center",
      "Payment Term",
      "Note",
      "Billing_type",
      "Creation Date",
      "Address",
      "Due Date",
      "Serial Number",
      "Tax Type",
      "Discount",
      "Remaining Amount",
      "Prepaid",
      "Invoice Frequency(In Months)",
      "Escalation Percentage",
      "Start Date",
      "End Date",
      "Description",
      "Comment",
      "Quantity",
      "Unit of Measurement",
      "Expected Rate",
      "Discount(In Percentage)",
      "Taxable Amount",
      "Tax Rate",
      "Tax Amount",
      "Total Amount",
      "TDS Type",
      "Remaining Amount",
      "Maximum Invoice Amount",
      "Available Invoice Amount",
      "Lockin Period(In Days)",
      "Rent Free Period(In Days)"
    ]
  end

  def security_deposit_headers
    [ 
      # Use this key for beneficiary payments too
      "Payable Amount"
    ]
  end

  def beneficiary_payment_headers
    []
  end

  def general_invoice_contents
    if self.general_invoice_items.present?
      self.general_invoice_items
    end
  end

  def rental_invoice_contents
    if rental_invoices_items.present?
      self.rental_invoices_items
    end
  end

  def security_deposit_contents
    if self.security_deposits_items.present?
      self.security_deposits_items
    end
  end

  def beneficiary_payment_contents
    if self.beneficiary_payments_items.present?
      self.beneficiary_payments_items
    end
  end

end