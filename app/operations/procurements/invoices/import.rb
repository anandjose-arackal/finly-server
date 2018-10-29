class Procurements::Invoices::Import < Procurements::Invoices::Base

  attr_accessor :company, :invoices_data, :file, :headers, :data,
                :contents, :invoices_params, :attr_mapping, :has_errors,
                :validation_data

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
    self.has_errors = false

    attachments_op = Procurements::Attachments::Index.(user, params)

    # Data required for validating each line item
    self.validation_data = {
      vendor_ids: user.company.yes_bank_vendors.pluck(:id), # todo change to vendor_id
      payment_terms: user.company.payment_terms,
      inventory_line_item_ids: user.company.inventory_line_items.pluck(:id),
      tax_rates: user.company.tax_rates,
      policies: user.company.policies.with_application(:vp),
      sub_departments: user.company.departments.only_sub_departments,
      locations: user.company.locations,
      attachments: attachments_op.attachments
    }


    self.invoices_params = generate_invoices_params
  end

  def validate
    unique_invoices_data = invoices_data.uniq { |item| [item[:vendor_uid], item[:invoice_number], item[:inventory_line_item_id], item[:amount]] }
    # unless unique_invoices_data.length == invoices_data.length
    #   add_message :error, 'Possible duplicate invoices found. Please resolve before uploading again'
    # end

    duplicate_invoice_data = invoices_data - unique_invoices_data

    if duplicate_invoice_data.present?
      self.invoices_params.each_with_index do |invoice_params, index|
        content = invoices_data[index].values
        if duplicate_invoice_data.index(invoices_data[index])
          self.has_errors = true

          error_message = ['Duplicate Invoice']

          content.push "ERROR"
          content.push error_message.join(", ")


          self.contents << content.map{|i| add_warning(i)}
        else

          self.contents << content
        end
      end
      return
    end


    self.invoices_params.each_with_index do |invoice_params, index|
      content = invoices_data[index].values
      error_message = []

      invoice_build_params = get_invoice_build_params(invoice_params)

      invoice = user.company.inward_invoices.build(invoice_build_params)

      # Validate vendor
      vendor_id = invoice_params[:vendor_id]&.to_i
      if vendor_id.blank? || self.validation_data[:vendor_ids].exclude?(vendor_id)
        content[0] = add_error(content[0])
        error_message.push("Invalid Vendor")
      end

      # Check Invoice number presence
      invoice_number = invoice_params[:invoice_number]&.to_s
      if invoice_number.blank?
        content[1] = add_error(content[1])
        error_message.push("Invoice Number Required")
      end

      # Validate sub department
      sub_department_id = invoice_params[:sub_department_id]
      if sub_department_id.blank?
        content[14] = add_error(content[14])
        error_message.push("Invalid Sub Department")
      end


      # Validate policy
      policy_id = invoice_params[:policy_id]
      if policy_id.blank?
        content[13] = add_error(content[13])
        error_message.push("Invalid Policy")
      end

      # Validate line item
      inventory_line_item_id = invoice_params[:invoice_items_attributes][0][:inventory_line_item_id]
      if inventory_line_item_id.blank?
        content[5] = add_error(content[5])
        error_message.push("Invalid Inventory Item ID")
      end

      # Validate attachment
      attachment_id = content[12]&.to_i
      if attachment_id.present? && attachment_id != 0 && validation_data[:attachments].pluck(:id).exclude?(attachment_id)
        content[12] = add_error(content[12])
        error_message.push('Invalid Attachment ID')
      end


      if invoice_params[:invoice_items_attributes][0][:amount_attributes][:value].to_f == 0
        content[8] = add_error(content[8])
        error_message.push("Amount can't be 0")
      end

      unless invoice_params[:invoice_items_attributes][0][:comment].present?
        content[6] = add_error(content[6])
        error_message.push("Comment can't be blank")
      end

      unless invoice.valid?
        self.has_errors = true
      end

      if error_message.present?
        content.push "ERROR"
        content.push error_message.join(", ")
      else
        content.push "OK"
      end

      self.contents << content
    end
  end

  def process
    unless has_errors
      add_message :success, 'All data will be processed'

      params[:processed_invoices_params] = invoices_params
      # Call background operations
      ::Procurements::Invoices::ImportProcessor.call(user.id, params)

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
      string.to_s + "---error---"
    else
      "---error---"
    end
  end

  def add_warning(string)
    self.has_errors = true
    if string.present?
      string.to_s + "---warning---"
    else
      "---warning---"
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

  def get_invoice_build_params(invoice_params)
    new_invoice_params = invoice_params.clone
    new_invoice_params.delete(:auto_submit)
    new_invoice_params.delete(:attachments)
    new_invoice_params
  end

  def generate_invoices_params
    invoices_params = []
    self.invoices_data.each do |data|
      inventory_line_item_op = Invoicing::InventoryLineItem::Index.(user, {filter_item_type: [SupplyItemType.id_for(:non_po_item)]})

      inventory_line_item = inventory_line_item_op.inventory_line_items.find_by id: data[:inventory_line_item_id]
      vendor = user.company.yes_bank_vendors.find_by(id: data[:vendor_uid]) # todo find by vendor uid

      receiving_account = vendor&.bank_accounts&.first
      sub_department = self.validation_data[:sub_departments]&.find_by(name: data[:sub_department_name])
      department = sub_department&.parent
      cost_center = sub_department&.cost_center
      policy = user.company.policies.find_by name: data[:policy_name]
      tax_rate = user.company.tax_rates.find_by id: data[:tax_rate_id]

      payment_term = user.company.payment_terms.find_by(name: data[:pyament_term_name])

      amount = data[:amount].to_f rescue 0
      quantity = data[:quantity].to_i rescue 1

      rate = amount / quantity
      discount = data[:discount].to_f rescue 0

      attachments = []
      attachment = validation_data[:attachments]&.find_by(id: data[:attachment_id])
      if attachment.present?
        attachments.push(attachment.id)
      end

      invoice_params = {
          vendor_id: vendor&.id,
          invoice_number: data[:invoice_number],
          invoice_status_id: ::InwardInvoiceStatus.id_for(:open),
          created_by_user_id: user.id,
          invoice_type_id: ::InwardInvoiceType.id_for(:tax_invoice),
          payment_term_id: payment_term&.id,
          date: data[:date],
          due_date: data[:due_date],
          receiving_account_id: receiving_account&.id,
          location_id: data[:location_id]&.to_i,
          delivery_location_id: data[:delivery_location_id]&.to_i,
          sub_department_id: sub_department&.id,
          department_id: department&.id,
          cost_center_id: cost_center&.id,
          policy_id: policy&.id,
          auto_submit: data[:auto_submit],
          attachments: attachments,
          invoice_items_attributes: [{
              inventory_line_item_id: inventory_line_item&.id,
              tax_rate_id: tax_rate&.id,
              description: inventory_line_item&.description,
              category_id: inventory_line_item&.category_id,
              comment: data[:comment],
              hsn_sac: inventory_line_item&.hsn_sac,
              amount_attributes: {
                  value: amount,
                  currency_id: 1
              },
              rate: rate,
              quantity: quantity,
              discount: discount
          }]
      }

      invoices_params.push invoice_params

    end
    invoices_params
  end
end