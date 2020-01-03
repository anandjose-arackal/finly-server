class Personalizer::Adapters::Company164::InvoicesTemplates< Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :invoices

  has_scope :filter_creation_date, using: [:from, :to], type: :hash

  def pre_validate

  end

  def init
    self.headers = [
        'S. NO.',
        'Report ID','Voucher Type',
        'Period',
        'Voucher Date',
        'Description',
        'Invoice amount',
        'Invoice Number',
        'Invoice Date',
        'Invoice Type',
        'State',
        'Supplier GSTN',
        'Place Of Supply',
        'Account',
        'Sub Account',
        'Department',
        'Cost Center',
        'Tax',
        'Tax Exemption(%)',
        'Base Amount',
        'Debit',
        'Credit',
        'Comments',
        'Supplier',
        'Reference Code',
        'SAC',
        'Ref. Invoice No.',
        'Remarks/Notes/Explanation'

    ]
    company = user.company
    self.invoices = Invoice.where(company_id: company.id, invoice_type_id: [1,3]).where(invoice_status_id: [3,10]).includes(:payments, :paid_amount, :amount, :created_by)
    self.invoices = apply_scopes(self.invoices, params)

    self.contents = []
    sl_no = 1
    invoices.each do |inv|
      row = [sl_no,
            inv.invoice_id,
            'BP',
            inv.date&.strftime("%Y%m"),
            inv.date&.strftime("%d/%m/%Y"),
            get_description(inv),
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '43181001',
            '',
            '',
            '',
            '',
            '',
            '',
            (inv.paid_amount&.value || 0.0),
            '',
            '',
            inv.receiving_account_id,
            inv.payments&.first&.reference_resource&.bank_reference_number
            ]
      contents << row
      row = [sl_no,
             inv.invoice_id,
             'BP',
             inv.date&.strftime("%Y%m"),
             inv.date&.strftime("%d/%m/%Y"),
             get_description(inv),
             '',
             '',
             '',
             '',
             '',
             '',
             '',
             '61110004',
             inv.created_by_id,
             '',
             '',
             '',
             '',
             '',
             '',
             (inv.paid_amount&.value || 0.0),
             '',
             inv.receiving_account_id,
             inv.payments&.first&.reference_resource&.bank_reference_number
      ]
      contents << row
      sl_no +=1
    end

  end

  def get_description(inv)
    payment_ids = inv.payments&.pluck(:id)&.join(',')
    "Being Payment made against various Payment IDs #{payment_ids}"
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end