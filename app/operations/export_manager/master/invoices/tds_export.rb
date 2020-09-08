class ExportManager::Master::Invoices::TdsExport < ExportManager::Builders::Template

  label 'Tds Export'
  description 'Tds Export'
  export_format 'csv'
  resource 'invoices'
  subscribe 'invoices'
  default true

  query Hash({
    qs: {
      invoice_status_id_eq_any: InwardInvoiceStatus.ids_for(%i[partially_paid paid])
    }
  })

  attribute :invoice_number, template: '{{ record.invoice_number }}'
  attribute :finly_ref_no, template: '{{ record.invoice_id }}'
  attribute :invoice_date, template: "{{ record.date | date: '%d-%b-%y' }}"
  attribute :invoice_status, template: '{{ record.status.name }}'
  attribute :invoice_type, template: '{{ record.invoice_type.name }}'
  attribute :created_by, template: '{{ record.created_by.name }}'
  attribute :tds_gl_code, template: '{{ record.tds_slab.gl_code }}'
  attribute :legal_status, template: '{{ record.vendor_location.gstin_master.constitution_of_business }}'
  attribute :pan, template: '{{ record.vendor.pan }}'
  attribute :vendor_id, template: '{{ record.vendor.vendor_id }}'
  attribute :vendor_name, template: '{{ record.vendor.display_name }}'
  # attribute :payment_date
  attribute :total_invoice_amount, template: '{{ record.total_invoice_amount }}'
  attribute :invoice_base_amount, template: '{{ record.base_amount }}'
  attribute :tds_name, template: '{{ record.tds_slab.name }}'
  attribute :tds_payable, template: '{{ record.tds_rate }}'
  attribute :tds_amount, template: '{{ record.tds_amount_value }}'
  attribute :cgst_sgst_amount, template: '{{ record.cgst_amount }}'
  attribute :igst_amount, template: '{{ record.igst_amount }}'
  attribute :amount_paid, template: '{{ record.payment_amounts_total }}'

  # def input
  #   invoices = Resolver::Router.dispatch('invoices.default', {current_user: user, params: params})
  #   invoices.where(invoice_status_id: InwardInvoiceStatus.ids_for([:partially_paid, :paid])).left_joins(:payments)
  # end

  # def finly_ref_no(invoice)
  #   invoice.invoice_id
  # end

  # def invoice_status(invoice)
  #   invoice&.status&.name&.humanize
  # end

  # def invoice_type(invoice)
  #   # [:tax_invoice, :advance, :non_po_invoice, :beneficiary, :proforma_invoice]
  #   invoice.invoice_type&.name&.titleize
  # end

  # def created_by(invoice)
  #   invoice&.created_by&.name
  # end

  # def tds_gl_code(invoice)
  #   invoice.tds_slab&.gl_code
  # end

  # def tds_payable(invoice)
  #   invoice.tds
  # end

  # # TODO VENDOR LEGAL STATUS DONE

  # def legal_status(invoice)
  #   invoice.vendor_location&.gstin_master&.constitution_of_business
  # end

  # def pan(invoice)
  #   invoice.vendor&.pan
  # end

  # def vendor_id(invoice)
  #   invoice.vendor&.vendor_id
  # end

  # def vendor_name(invoice)
  #   invoice.vendor&.display_name
  # end

  # # TODO PAYMENT DATE DONE

  # def payment_date(invoice)
  #   invoice.payments.order(created_at: :desc).first&.created_at&.strftime("%d-%b-%y")
  # end

  # def amount_paid(invoice)
  #   invoice.payments.successful.map {|p| p.amount&.value if (p.payment_status_id == PaymentStatus.id_for(:completed))}.compact.sum
  # end

  # def cgst_sgst_amount(invoice)
  #   invoice.gst_type_id == GstType.id_for(:cgst_sgst) ? invoice.tax_amount&.value.to_f / 2.0 : 0
  # end

  # def igst_amount(invoice)
  #   invoice.gst_type_id == GstType.id_for(:igst) ? invoice.tax_amount&.value.to_f : 0
  # end

  # # TODO ADD TOTAL INVOICE AMOUNT amt + gst DONE

  # def total_invoice_amount(invoice)
  #   invoice.gross_amount&.value.to_f + invoice.tax_amount&.value.to_f
  # end

  # def invoice_number(invoice)
  #   invoice.invoice_number
  # end

  # def invoice_date(invoice)
  #   invoice.date&.strftime("%d-%b-%y")
  # end

  # def invoice_base_amount(invoice)
  #   invoice.include_original_amount
  # end

  # # TODO TDS TAX CODE DONE merged to tds_name
  # # TODO TDS TAX SECTION DONE

  # def tds_name(invoice)
  #   invoice.tds_slab&.name
  # end

  # def tds_amount(invoice)
  #   invoice.tds_amount&.value
  # end

  # def tds_rate(invoice)
  #   invoice.tds
  # end

end
