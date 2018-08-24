class Integrations::NetSuite::Invoices < Integrations::NetSuite::Base
  attr_accessor :payment_requests

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless current_company.accounting_system_configuration.present? and current_company.accounting_system_configuration.enabled
      add_message :error, 'NetSuite has not been configured for your company'
      return
    end
    if params[:id].blank?
      add_message :error, 'Payment Ticket not found'
      return
    end
  end

  def init
    result = BankTransfer::PaymentRequest::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.payment_requests = result.payment_requests.with_id(params[:id])
  end

  def validate
    if self.payment_requests.blank?
      add_message :error, 'Payment Ticket not found'
      return
    end
  end

  def process
    headers = net_suite_headers
    contents = []
    self.payment_requests.each do |payment_request|
      payment_request.payments.each do |payment|
        invoice = payment.invoice
        invoice.invoice_items.each do |item|
          tds_applied = (invoice.tds_slab&.tds && invoice.tds_slab&.tds > 0) ? 'Yes' : 'No'
          contents << [
              '',
              (contents.size + 1),
              invoice.vendor.display_name,
              item.description,
              'Indian Rupee',
              invoice.invoice_number,
              current_company.accounting_system_configuration.options[:account],
              item.comment,
              1,
              Date.today.strftime('%d/%m/%y'),
              Date.today.strftime('%b-%y'),
              invoice.date&.strftime('%d/%m/%y'),
              'Wire',
              item.inventory_line_item&.item_code,
              item.quantity,
              item.net_amount&.value,
              item.inventory_line_item&.tax_rate&.internal_id,
              tds_applied,
              invoice.tds_slab&.name,
              invoice.procurement.purchase_order.department.name,
              invoice.procurement.purchase_order.department.name,
              invoice.procurement.purchase_order.location.name,
              item.rate

          ]
        end
      end
    end
    self.response = Exporter::Spreadsheet.new(user, {headers: headers, contents: contents, file_name: 'export'}, messages)
  end

  def success
    self.response
  end

  def net_suite_headers
    [
        "External ID",
        "Line Id",
        "Vendor",
        "Header Memo",
        "Currency",
        "REFERENCE NO.",
        "Account",
        "Memo",
        "Exchange Rate",
        "Posting Date",
        "Posting Period",
        "INVOICE DATE",
        "Vendor Payment Method",
        "Item",
        "Quantity",
        "Amount",
        "Taxcode",
        "TDS Apply",
        "TDS Category",
        "Department",
        "website",
        "Location",
        "Base Amount"
    ]
  end

end