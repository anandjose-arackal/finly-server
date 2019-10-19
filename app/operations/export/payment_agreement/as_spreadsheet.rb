class Export::PaymentAgreement::AsSpreadsheet < Export::PaymentAgreement::Base

  attr_accessor :headers, :contents, :general_invoice_items, :rental_invoice_items, :security_deposits_items, :beneficiary_payments_items

  def init
    # self.headers ||= []
    # self.contents ||= []
    # self.payment_agreement_contents ||= []
  end

  def process
    self.headers = []
    self.contents = []
    result_presenter = ::PaymentAgreements::Index.(user, params)
    unless result_presenter.success?
      add_message :error, result_presenter.messages[:error]
      return
    end
    self.headers = payment_agreement_headers + invoice_headers + security_deposit_headers

    payment_agreements = result_presenter.payment_agreements
    payment_agreements.limit(2).each do |payment_agreement|
      general_invoice_item_ids = payment_agreement.general_invoices.joins(:invoice_items).pluck('invoice_line_items.id')
      rental_invoice_item_ids = payment_agreement.rental_invoices.joins(:invoice_items).pluck('invoice_line_items.id')
      general_invoice_items = InvoiceLineItem.where(id: general_invoice_item_ids)
      rental_invoice_item_ids = payment_agreement.rental_invoices.joins(:invoice_items).pluck('invoice_line_items.id')

      rental_invoice_items = InvoiceLineItem.where(id: rental_invoice_item_ids)
      rental_invoices_item_ids = payment_agreement.rental_invoices.joins(:invoice_items).pluck('invoice_line_items.id')
      self.security_deposits_items = payment_agreement.security_deposits
      self.beneficiary_payments_items = payment_agreement.beneficiary_payments
      self.contents << invoice_item_contents(general_invoice_items, rental_invoice_items) #+ security_deposit_contents + beneficiary_payment_contents
    end

    # self.contents += invoice_item_contents #+ security_deposit_contents + beneficiary_payment_contents

  end

  def post_process
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'payment_agreement'}, messages)
  end

  def payment_agreement_headers
    [
      "Agreement Type",
      "Agreement Number",
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
      # "Remaining Amount",
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
      "Billing Type",
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

  def invoice_item_contents(general_invoice_items=nil, rental_invoice_items=nil)
    if general_invoice_items.present?
      content_arr = []
      general_invoice_items.each do |invoice_item|
        agreement = invoice_item.parent.payment_agreement
        content_arr += payment_agreement_contents(agreement)
        content_arr += [invoice_item.parent_type.titleize]
        # payment_agreement_contents += payment_agreement_contents(agreement)
        content_arr += agreement_invoice_item_contents(invoice_item)
      end
      return content_arr
    end
    return []
  end


  def payment_agreement_contents(agreement)
    [
      agreement.get_agreement_number,
      agreement.title,
      agreement.policy.name,
      agreement.agreement_date,
      agreement.execution_date,
      agreement.expiration_date,
      agreement.renewal_date,
      agreement.no_expiration,
      agreement.created_at.to_date,
      agreement.reject_note,
      agreement.renewal_reminder_date,
      # agreement.balance_due.value,
      agreement.status.name.titleize,
      agreement.termination_reason,
      agreement.terminated_at&.to_date,
      agreement.creator.name,
      agreement.terminated_by&.name
    ]
  end

  def agreement_invoice_item_contents(invoice_item)
    [
      invoice_item.parent.vendor&.display_name,
      invoice_item.parent.vendor_location&.location,
      invoice_item.parent.vendor.vendor_id,
      invoice_item.parent&.invoice_bank_account&.name,
      invoice_item.parent&.invoice_bank_account&.account_number,
      invoice_item.parent.department&.name,
      invoice_item.parent.location&.name,
      invoice_item.parent.cost_center&.name,
      invoice_item.parent.payment_term&.name,
      invoice_item.parent&.note,
      invoice_item.parent.billing_type&.name,
      invoice_item.parent.created_at.to_date,
      "",
      invoice_item.parent.due_date,
      invoice_item.parent.get_invoice_number,
      invoice_item.parent.tax_type_id,
      "",
      invoice_item.parent.balance_due.value,
      invoice_item.parent.prepaid,
      invoice_item.parent&.invoice_frequency&.period,
      invoice_item.parent.try(:escalation_percentage),
      invoice_item.parent.start_date,
      invoice_item.parent.end_date,
      invoice_item.description,
      invoice_item.comment,
      invoice_item.quantity,
      invoice_item.unit_of_measurement,
      invoice_item.rate,
      invoice_item.discount,
      invoice_item&.taxable_amount&.value,
      invoice_item&.tax_rate&.rate,
      invoice_item.tax_amount.value,
      invoice_item.amount&.value,
      "",
      invoice_item.parent.balance_due.value,
      invoice_item.parent.try(:total_invoice_amount).try(:value),
      invoice_item.parent.try(:available_invoice_amount).try(:value),
      invoice_item.parent.try(:lockin_period),
      invoice_item.parent.try(:rent_free_period)
    ]
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