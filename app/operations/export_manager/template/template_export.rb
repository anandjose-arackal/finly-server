class ExportManager::Template::TemplateExport < ExportManager::API

  # TODO: Do this in different way
  def input
    ExportManager::Template::InvoiceLineItems::Index.input user, params
  end

  def template
    # TODO: change this to fetch from db
    {
      "columns": [
        {
          "label": "Invoice number",
          "value": "{{ record.invoice.invoice_number }}"
        },
        {
          "label": "Finly ref no.",
          "value": "{{ record.invoice.invoice_id }}"
        },
        {
          "label": "Finly approved date",
          "value": "{{ record.invoice.approved_at | date: '%d-%b-%Y' }}"
        },
        {
          "label": "Vendor gstin",
          "value": "{{ record.invoice.gstin_location.gstin }}"
        },
        {
          "label": "Billing location",
          "value": "{{ record.invoice.billing_location.name }}"
        },
        {
          "label": "Shipping location",
          "value": "{{ record.invoice.shipping_location.name }}"
        },
        {
          "label": "Gl code",
          "value": "{{ record.category.gl_code }}"
        },
        {
          "label": "Description",
          "value": "{{ record.description }}"
        },
        {
          "label": "Invoice net payable amount",
          "value": "{{ record.invoice.balance_due_value }}"
        },
        {
          "label": "Invoice base amount",
          "value": "{{ record.invoice.base_amount }}"
        },
        {
          "label": "Total tax",
          "value": "{{ record.tax_amount.value }}"
        },
        {
          "label": "Item rate",
          "value": "{{ record.rate }}"
        },
        {
          "label": "Item igst amount",
          "value": "{{ record.igst_amount }}"
        },
        {
          "label": "Item cgst amount",
          "value": "{{ record.cgst_amount }}"
        },
        {
          "label": "Item sgst amount",
          "value": "{{ record.sgst_amount }}"
        },
        {
          "label": "Item igst",
          "value": "{{ record.igst }}"
        },
        {
          "label": "Item cgst",
          "value": "{{ record.cgst }}"
        },
        {
          "label": "Item sgst",
          "value": "{{ record.sgst }}"
        },
        {
          "label": "Igst account number",
          "value": "{{ record.tax_rate.igst_account_number }}"
        },
        {
          "label": "Cgst account number",
          "value": "{{ record.tax_rate.cgst_account_number }}"
        },
        {
          "label": "Sgst account number",
          "value": "{{ record.tax_rate.sgst_account_number }}"
        },
        {
          "label": "Hsn sac",
          "value": "{{ record.hsn_sac }}"
        },
        {
          "label": "Reverse charge",
          "value": "0"
        },
        {
          "label": "Reverse charge tax gl account",
          "value": "N"
        },
        {
          "label": "Calculate tax for rct",
          "value": "N"
        },
        {
          "label": "Invoice status",
          "value": "{{ record.invoice.status.name }}"
        },
        {
          "label": "Itc qualified",
          "value": "{{ record.itc_qualified }}"
        },
        {
          "label": "Country",
          "value": "{{ record.country }}"
        },
        {
          "label": "Vendor name",
          "value": "{{ record.invoice.vendor.business_name }}"
        },
        {
          "label": "Department code",
          "value": "{{ record.department.department_code }}"
        }
      ]
    }
  end

  def processor_class
    # TODO: relook at this to see if there is a good way to get processor
    case format
    when :xls
      ExportManager::Template::Processors::XlsProcessor
    when :csv
      ExportManager::Template::Processors::CSVProcessor
    when :xml
      ExportManager::Template::Processors::XMLProcessor
    when :json
      ExportManager::Template::Processors::JSONProcessor
    when :other
      ExportManager::Template::Processors::TextProcessor
    end
  end

  def generate
    processor = processor_class.new export_job
    file = processor.generate template, data, file_name
    if file
      save_attachment file
      success!
    else
      failure!
    end
  end

  def file_name
    # TODO: update to include template name in file name
    case format
    when :csv
      ['export', '.csv']
    when :xls
      ['export', '.xls']
    when :json
      ['export', '.json']
    when :xml
      ['export', '.xml']
    when :other
      ['export']
    end
  end

  def format
    params[:export_format]&.to_sym || :xls
  end

end
