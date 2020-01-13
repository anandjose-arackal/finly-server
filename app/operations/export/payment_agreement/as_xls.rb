class Export::PaymentAgreement::AsXls < Export::PaymentAgreement::Base

  attr_accessor :headers, :contents, :general_invoice_items, :rental_invoice_items, :security_deposit_items, :beneficiary_payment_items, :download_url, :file_name

  def init
  end

  def process
    self.headers = []
    self.contents = []
    result_presenter = ::PaymentAgreements::Index.(user, params)
    unless result_presenter.success?
      add_message :error, result_presenter.messages[:error]
      return
    end
    self.file_name = "payment-agreement-export-#{Date.today}.xls"
    self.headers = payment_agreement_headers + invoice_headers + security_deposit_headers
    payment_agreements = result_presenter.payment_agreements
    payment_agreements.joins(:general_invoices).order(created_at: :desc).each do |payment_agreement|
      general_invoice_item_ids = payment_agreement.general_invoices.joins(:invoice_items).pluck('invoice_line_items.id')
      rental_invoice_item_ids = payment_agreement.rental_invoices.joins(:invoice_items).pluck('invoice_line_items.id')
      general_invoice_items = InvoiceLineItem.where(id: general_invoice_item_ids)
      rental_invoice_item_ids = payment_agreement.rental_invoices.joins(:invoice_items).pluck('invoice_line_items.id')

      rental_invoice_items = InvoiceLineItem.where(id: rental_invoice_item_ids)
      self.security_deposit_items = payment_agreement.security_deposits
      self.beneficiary_payment_items = payment_agreement.beneficiary_payments
      export_contents = invoice_item_contents(general_invoice_items, rental_invoice_items) + security_deposit_contents + beneficiary_payment_contents 
      self.contents += export_contents
    end

  end

  def post_process
  end

  def success
    exportable_file = Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents, filename: 'payment_agreement'}, messages).generate_xls
    self.download_url = create_temporary_link(exportable_file)
    params[:download_url] = self.download_url
    Export::PaymentAgreement::AsXls::AsXlsPresenter.new(user , params, messages)
  end


  class Export::PaymentAgreement::AsXls::AsXlsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :download_url

    def init
      self.download_url = params[:download_url]
    end
  end

  def payment_agreement_headers
    [
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
      "Agreement Item Type",
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
      "Tax Rate(In Percentage)",
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
    content_arr = []
    if general_invoice_items.present?
      general_invoice_items.each do |invoice_item|
        agreement = invoice_item.parent.payment_agreement
        general_invoice_contents = payment_agreement_contents(agreement) + agreement_invoice_item_contents(invoice_item) rescue []
        content_arr << general_invoice_contents
        # content_arr += payment_agreement_contents(agreement)
        # payment_agreement_contents += payment_agreement_contents(agreement)
        # content_arr += agreement_invoice_item_contents(invoice_item)
      end
    end

    if rental_invoice_items.present?
      rental_invoice_items.each do |invoice_item|
        agreement = invoice_item.parent.payment_agreement
        rental_invoice_contents = payment_agreement_contents(agreement) + agreement_invoice_item_contents(invoice_item) rescue []
        content_arr << rental_invoice_contents
        # content_arr += payment_agreement_contents(agreement)
        # payment_agreement_contents += payment_agreement_contents(agreement)
        # content_arr += agreement_invoice_item_contents(invoice_item)
      end
    end
    return content_arr
  end


  def payment_agreement_contents(agreement)
    [
      agreement.get_agreement_number,
      agreement.title,
      agreement.policy.name,
      agreement.agreement_date&.to_date,
      agreement.execution_date&.to_date,
      agreement.expiration_date&.to_date,
      agreement.renewal_date&.to_date,
      agreement.no_expiration,
      agreement.created_at.to_date,
      agreement.reject_note,
      agreement.renewal_reminder_date&.to_date,
      # agreement.balance_due.value,
      agreement&.status&.name&.titleize,
      agreement.termination_reason,
      agreement.terminated_at&.to_date,
      agreement.creator&.name,
      agreement.terminated_by&.name
    ]
  end

  def agreement_invoice_item_contents(invoice_item)
    [ invoice_item.parent_type.titleize,
      invoice_item.parent.vendor&.display_name,
      invoice_item.parent.vendor_location&.location,
      invoice_item.parent&.vendor&.vendor_id,
      invoice_item.parent&.invoice_bank_account&.name,
      invoice_item.parent&.invoice_bank_account&.account_number,
      invoice_item.parent&.department&.name,
      invoice_item.parent&.location&.name,
      invoice_item.parent&.cost_center&.name,
      invoice_item.parent&.payment_term&.name,
      invoice_item.parent&.note,
      invoice_item.parent&.billing_type&.name&.titleize,
      invoice_item.parent.created_at.to_date,
      "",
      invoice_item.parent.due_date,
      invoice_item.parent.get_invoice_number,
      invoice_item.parent.tax_type_id,
      "",
      invoice_item.parent.balance_due.value,
      invoice_item.parent.prepaid,
      invoice_item.parent&.invoice_frequency&.number,
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
    content_arr = []
    if self.security_deposit_items.present?
      self.security_deposit_items.each do |security_deposit_item|
        agreement = security_deposit_item.payment_agreement
        item_contents = payment_agreement_contents(agreement) + security_deposit_item_contents(security_deposit_item)
        # content_arr += security_deposit_item_contents(security_deposit_item)
        content_arr << item_contents
      end
    end
    return content_arr
  end

  def security_deposit_item_contents(security_deposit_item)
    [ 'Security Deposit',
      security_deposit_item.vendor&.display_name,
      security_deposit_item.vendor_location&.location,
      security_deposit_item&.vendor&.vendor_id,
      security_deposit_item&.bank_account&.name,
      security_deposit_item&.bank_account&.account_number,
      security_deposit_item&.department&.name,
      security_deposit_item&.location&.name,
      security_deposit_item&.cost_center&.name,
      "",
      security_deposit_item&.note,
      "",
      security_deposit_item.created_at.to_date,
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      security_deposit_item.payable_amount&.value
    ]
  end

  def beneficiary_payment_contents
    content_arr = []
    if self.beneficiary_payment_items.present?
      self.beneficiary_payment_items.each do |beneficiary_payment_item|
        agreement = beneficiary_payment_item.payment_agreement
        item_contents = payment_agreement_contents(agreement) + beneficiary_payment_item_contents(beneficiary_payment_item)
        content_arr << item_contents
      end
    end

    content_arr = []
  end

  def beneficiary_payment_item_contents(beneficiary_payment_item)
    [ 'Beneficiary Payment',
      beneficiary_payment_item.vendor&.display_name,
      beneficiary_payment_item.vendor_location&.location,
      beneficiary_payment_item&.vendor&.vendor_id,
      beneficiary_payment_item&.bank_account&.name,
      beneficiary_payment_item&.bank_account&.account_number,
      beneficiary_payment_item&.department&.name,
      beneficiary_payment_item&.location&.name,
      beneficiary_payment_item&.cost_center&.name,
      "",
      beneficiary_payment_item&.note,
      "",
      beneficiary_payment_item.created_at.to_date,
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      beneficiary_payment_item&.payable_amount&.value
    ]
  end


  def create_temporary_link(file)
    return nil if file.nil?
    temp_file = File.open(self.file_name, 'wb')
    temp_file.write file
    temp_file.rewind
    # temp_file
    t = TemporaryFile.create(file: temp_file, expires_on: (DateTime.now + 1.day))
    File.delete(temp_file.path)
    unless t.valid?
      add_message :error, t.errors.full_messages
      return
    end
    t.file.url
  end


end