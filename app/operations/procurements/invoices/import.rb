class Procurements::Invoices::Import < Procurements::Invoices::Base

  attr_accessor :company, :invoices_data, :file, :headers, :data,
                :contents, :invoices_params, :attr_mapping, :has_errors

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

    self.attr_mapping = [
        :vendor_uid, # 0
        :invoice_number, # 1
        :date, # 2
        :due_date, # 3
        :payment_term_name, # 4
        :inventory_line_item_id, # 5
        :comment, # 6
        :quantity, # 7
        :amount, # 8
        :tax_rate_id, # 9
        :total, # 10
        :period, # 11
        :attachment_id, # 12
        :policy_name, # 13
        :sub_department_name, # 14
        :location_id, # 15
        :delivery_location_id, # 16
        :auto_submit # 17
    ]

    self.invoices_data = ImportUtil.load_spreadsheet(file, self.attr_mapping, {skip_empty_lines: true})

    if self.invoices_data.blank?
      add_message :error, "Empty spreadsheet uploaded"
    end

    self.headers = retrieve_headers
    self.contents = []
    self.invoices_params = generate_invoices_params
    self.has_errors = false
  end

  def validate
    unique_invoices_data = invoices_data.uniq { |item| [item[:vendor_uid], item[:invoice_number], item[:inventory_line_item_id], item[:amount]] }
    unless unique_invoices_data.length == invoices_data.length
      add_message :error, 'Possible duplicate invoices found. Please resolve before uploading again'
    end


    self.invoices_params.each_with_index do |invoice_params, index|
      has_line_item_errors = false
      content = invoices_data[index].values
      invoice = user.company.inward_invoices.build(invoice_params)

      unless invoice_params[:vendor_id].present?
        content[0] = add_error(content[0])
        has_line_item_errors = true
      end

      unless invoice_params[:invoice_number].present?
        content[1] = add_error(content[1])
        has_line_item_errors = true
      end

      unless invoice_params[:sub_department_id].present?
        content[14] = add_error(content[14])
        has_line_item_errors = true
      end

      unless invoice_params[:policy_id].present?
        content[13] = add_error(content[13])
        has_line_item_errors = true
      end

      unless invoice_params[:invoice_items_attributes][0][:inventory_line_item_id].present?
        content[5] = add_error(content[5])
        has_line_item_errors = true
      end

      unless invoice_params[:invoice_items_attributes][0][:rate].present?
        content[8] = add_error(content[8])
        has_line_item_errors = true
      end

      unless invoice_params[:invoice_items_attributes][0][:comment].present?
        content[6] = add_error(content[6])
        has_line_item_errors = true
      end


      unless invoice.valid?
        self.has_errors = true
      end

      if has_line_item_errors
        content.push "ERROR"
      end

      self.contents << content
    end
  end

  def process
    unless has_errors
      add_message :success, 'All data will be processed'

      # Call background operations
      ::Procurements::Invoices::ImportProcessor.call(user, invoices_params)

    end

  end

  def post_process

  end

  def success
    params[:import_data] = {
        headers: self.headers,
        contents: self.contents
    }

    Procurements::Invoices::ImportTemplate.(user, params)

    # self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.contents, template: 'export_template/template_w_validation'}}, messages)
  end

  def add_error(string)
    self.has_errors = true
    if string.present?
      string.to_s + "---errror---"
    else
      "---error---"
    end
  end

  private

  def retrieve_headers
    [
        "Vendor ID",
        "Invoice Number",
        "Invoice Date",
        "Due Date",
        "Payment Term Name",
        "Item Id",
        "Comment",
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
              description: inventory_line_item&.description,
              comment: data[:comment],
              rate: data[:amount].to_f / (data[:quantity].to_i || 1),
              quantity: data[:quantity],
              discount: data[:discount]
          }]
      }

      invoices_params.push invoice_params

    end
    invoices_params
  end
end