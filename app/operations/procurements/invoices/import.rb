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

    self.invoices_data = ImportUtil.load_spreadsheet(file, [
        :vendor_uid, :invoice_number, :date, :due_date, :payment_term_name,
        :inventory_line_item_id, :description, :quantity, :amount, :tax_rate_id, :total,
        :period, :attachment_id, :policy_name, :sub_department_name, :location_id, :delivery_location_id,
        :auto_submit], {skip_empty_lines: true})

    if self.invoices_data.blank?
      add_message :error, "Empty spreadsheet uploaded"
    end


    self.headers = retrieve_headers
    self.contents = []
  end

  def validate
    unique_invoices_data = invoices_data.uniq { |item| [item[:vendor_uid], item[:invoice_number], item[:inventory_line_item_id], item[:amount]] }
    unless unique_invoices_data.length == invoices_data.length
      add_message :error, 'Possible duplicate invoices found. Please resolve before uploading again'
    end
  end

  def process
    self.invoices_params = generate_invoices_params

    self.invoices_params.each do |invoice_params|
      invoice = user.company.inward_invoices.build(invoice_params)

      unless invoice.valid?
        add_message :error, "Could not process data. Please resolve errors before tying again"
        break
      end
    end

    add_message :success, 'All data will be processed'
  end

  # def success
  #   self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.contents}}, messages)
  # end

  private

  def retrieve_headers
    [
        "Vendor ID",
        "Invoice Number",
        "Invoice Date",
        "Due Date",
        "Payment Term Name",
        "Item Id",
        "Description",
        "Qty",
        "Amount",
        "Tax Rate ID",
        "Total",
        "Period",
        "Attachment ID",
        "Policy Name",
        "Sub Department Name",
        "Billing Location ID",
        "Shipping Location ID",
        "Auto Submit (Yes/No)",
        "Status"
    ]
  end

  def generate_invoices_params
    invoices_params = []
    self.invoices_data.each do |data|
      inventory_line_item_op = Invoicing::InventoryLineItem::Index.(user, {filter_item_type: [SupplyItemType.id_for(:non_po_item)]})

      inventory_line_item = inventory_line_item_op.inventory_line_items.find_by id: data[:inventory_line_item_id]
      vendor = user.company.yes_bank_vendors.find_by(id: data[:vendor_uid]) # todo find by vendor uid

      receiving_account = vendor&.bank_accounts&.first
      sub_department = user.company.departments.only_sub_departments.find_by name: data[:sub_department_name]
      department = sub_department&.parent
      cost_center = sub_department&.cost_center
      policy = user.company.policies.find_by name: data[:policy_name]
      tax_rate = user.company.tax_rates.find_by id: data[:tax_rate_id]

      payment_term = user.company.payment_terms.find_by(name: data[:pyament_term_name])

      invoice_params = {
          vendor_id: vendor&.id,
          invoice_number: data[:invoice_number],
          invoice_status_id: ::InwardInvoiceStatus.id_for(:open),
          created_by_user_id: user.id,
          invoice_type_id: ::InwardInvoiceType.id_for(:tax_invoice),
          payment_term_id: payment_term&.id,
          due_date: data[:due_date],
          receiving_account_id: receiving_account&.id,
          location_id: data[:location_id]&.to_i,
          delivery_location_id: data[:delivery_location_id]&.to_i,
          sub_department_id: sub_department&.id,
          department_id: department&.id,
          cost_center_id: cost_center&.id,
          policy_id: policy&.id,
          invoice_items_attributes: [{
              inventory_line_item_id: inventory_line_item&.id,
              tax_rate_id: tax_rate&.id,
              description: data[:description],
              quantity: data[:quantity],
              rate: data[:amount],
              discount: data[:discount]
          }]
      }

      invoices_params.push invoice_params

    end
    invoices_params
  end
end