class Procurements::Invoices::Import < Procurements::Invoices::Base

  attr_accessor :company, :invoices_data, :file, :headers, :data, :contents, :invoices_params

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
    if params[:file].blank?
      add_message :error, "No file uploaded"
    end
  end

  def init
    self.company = user.company
    self.file = params[:file]

    self.invoices_data = ImportUtil.load_spreadsheet(file, [:vendor_uid, :invoice_number, :payment_term_name, :inventory_line_item_id, :amount, :tax_rate_id, :total, :period, :attachment_id, :sub_department_name, :auto_submit], {skip_empty_lines: true})

    if self.inventory_data.blank?
      add_message :error, "Empty spreadsheet uploaded"
    end

    self.invoices_params = generate_invoices_params

    self.headers = retrieve_headers
    self.contents = []
  end

  def validate

  end

  def process
    self.inventory_data.each do |data|
      content = data.values
      inventory_line_item = user.company.inventory_line_items.build(data)
      if inventory_line_item.save
        content << "Success"
      else
        content << inventory_line_item.errors.full_messages.to_sentence
      end

      self.contents << content
    end
  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.contents}}, messages)
  end

  private

  def retrieve_headers
    [
        "Vendor ID",
        "Invoice Number",
        "Payment Terms",
        "Item Id",
        "Amount",
        "Tax Rate ID",
        "Total",
        "Period",
        "Attachment ID",
        "Sub Department",
        "Auto Submit (Yes/No)",
        "Status"
    ]
  end

  def generate_invoices_params
    self.invoices_data.each do |data|
      inventory_line_item_op = Invoicing::InventoryLineItem::Index.(user, {filter_item_type: [SupplyItemType.id_for(:non_po_item)]})

      inventory_line_item = inventory_line_item_op.inventory_line_items.find_by id: data[:item_id]

      params = {
          vendor_id: user.company.yes_bank_vendors.find_by(id: data[:vendor_uid]),
          invoice_number: data[:invoice_number],
          payment_term_id: user.company.payment_terms.find_by(name: data[:pyament_term_name]),
          invoice_item_attributes: {
              inventory_line_item_id: inventory_line_item.id
          }
      }

    end
  end
end