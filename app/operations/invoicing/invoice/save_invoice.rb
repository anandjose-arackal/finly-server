# this checks the invoice for all validations and eventually saves the invoice which can now be sent to the customer
class Invoicing::Invoice::SaveInvoice < Invoicing::Invoice::Base

  attr_accessor :invoice, :invoice_parameters, :invoice_number, :invoice_current_attachments, :invoice_old_attachments, :invoice_type

  def init
    id = params[:id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: id)
    self.invoice_parameters = invoice_params
    if invoice
      self.invoice_type = invoice.outward_invoice_type.name
    end
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    if self.invoice.cancelled? || self.invoice.partially_paid? || self.invoice.paid?
      add_message :error, "Invoice cannot be edited in this state"
      return
    end

    # checking if the invoice number is unique for this company
    self.invoice_number = self.invoice_parameters[:invoice_number]
    if self.invoice_number.present? && self.user.company.outward_invoices.without_id(self.invoice.id).pluck(:invoice_number).include?(self.invoice_number)
      add_message :error, "This invoice number is already taken. Please enter a new one"
    end
  end

  def pre_process
    # add logic to remove line items if required
    if self.invoice_parameters&.dig(:invoice_items_attributes).present?
      self.invoice_parameters[:invoice_items_attributes].each do |data|
        if StringUtils.to_bool(data[:remove_line_item])
          data[:_destroy] = true
          data.delete(:remove_line_item)
        else
          data.delete(:remove_line_item)
        end
      end
    end

    # if nothing is passed inside invoice items attributes, assume that all are to be deleted
    if self.invoice_parameters&.dig(:invoice_items_attributes).blank?
      if self.invoice&.invoice_items.present?
        self.invoice_parameters[:invoice_items_attributes] = []
        self.invoice&.invoice_items.each do |item|
          self.invoice_parameters[:invoice_items_attributes] << {
              id: item.id,
              _destroy: true
          }
        end
      end
    end

    # adding the prefix and sequence to the invoice
    if user.company.invoice_number_configs.with_purpose_id(Purpose.id_for(:collect)).with_config_type_id(InvoiceNumberConfigType.id_for(self.invoice_type)).present?
      prefix = user.company.invoice_number_configs.with_purpose_id(Purpose.id_for(:collect)).with_config_type_id(InvoiceNumberConfigType.id_for(self.invoice_type)).first.prefix
    else
      prefix = ''
    end
    sequence = self.invoice_number&.gsub(prefix, '')
    self.invoice_parameters[:prefix] = prefix
    self.invoice_parameters[:sequence_start] = sequence

    # Extracting invoice attachments
    self.invoice_current_attachments = user.company.outward_invoice_attachments.with_id(invoice_parameters[:invoice_attachments])

    # Remove :invoice_attachments from parameters
    self.invoice_parameters.delete(:invoice_attachments)

    # Old Attachments
    self.invoice_old_attachments = invoice.attachments

    # creating the customer if the customer_id isn't present in the params for this request
    if invoice_parameters[:customer_id].blank? && params.dig(:customer, :id).blank?
      # try creating an invoice here
      cust_params = customer_params
      cust_params[:create_virtual_account] = true
      cust_params[:virtual_bank_accounts_attributes] = [{name: "#{customer_params[:name]}'s Virtual Account"}]
      cust_params = {customer: cust_params}
      op = Invoicing::Customer::Create.(user, cust_params)
      if op.success?
        self.invoice_parameters[:customer_id] = op.customer.id
        # add attributes of the customer to the invoice
        self.invoice_parameters[:virtual_account_id] = op.customer.virtual_bank_accounts.first&.id
      else
        add_message :error, op.messages[:error]
        return
      end
    end

    # check if customer id is inside the customer object, and add it to invoice if it is
    if params.dig(:customer, :id).present?
      customer = user.company.customers.find_by(id: params.dig(:customer, :id))
      if customer.blank?
        add_message :error, "This customer does not belong to your company"
        return
      end
      self.invoice_parameters[:customer_id] = params.dig(:customer, :id)
    end
  end

  def process
    # assign the attributes for this particular invoice first
    self.invoice.assign_attributes(self.invoice_parameters)
    # calculate the tax and discounts that need to be done for this particular invoice
    # and store it in the invoice object for further calculation
    self.invoice.invoice_items.each_with_index do |invoice_item, index|
      custom_fields = params&.dig(:invoice, :invoice_items_attributes)[index][:custom_fields]
      if custom_fields.present?
        set_custom_fields(false, invoice_item, custom_fields)
      end
    end
    calculate_tax_and_discounts
    unless self.invoice.valid?
      add_message :error, self.invoice.errors.full_messages
      return
    end

    self.invoice_old_attachments.update_all(outward_invoice_id: nil)

    self.invoice_current_attachments.update_all(outward_invoice_id: invoice.id)

    # checking if this particular operation has the customer's new GSTIN
    if params[:customer].present?
      if customer_params.present?
        self.invoice.customer.gst = customer_params[:gst]
      end
    end
    invoice_status_id = OutwardInvoiceStatus.id_for(:saved)
    if self.invoice.tax_invoice?
      invoice_status_id = OutwardInvoiceStatus.id_for(:unpaid)
    end

    if self.invoice.update(invoice_status_id: invoice_status_id, is_deleted: false)
      recalculate_totals
      self.invoice.update(paid_amount: Amount.create(value: 0, currency_id: 1)) # setting the paid amount as 0 at the time of saving
      self.invoice.virtual_account&.update(purpose_id: VirtualAccountPurpose.id_for(:invoice))
    else
      add_message :error, self.invoice.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, 'Invoice successfully saved'
  end

  def success
    params[:invoice] = self.invoice
    Invoicing::Invoice::Base::InvoicePresenter.new(user, params, messages)
  end

  private

  def invoice_params
    params.require(:invoice).permit(:gst_type_id, :tds, :tds_type_id, :category_id, :customer_id, :tds_slab_id,
                                    :tax_type_id, :date, :discount_type_id, :due_date, :memo, :customer_memo, :terms, :payment_term_id, :location_id,
                                    :invoice_number, :inclusive_of_taxes, :billing_address, :shipping_address, :override_invoice_number,
                                    :email, :mobile_number, :virtual_account_id, :roundoff_amount, :roundoff_total_enabled,
                                    original_amount_attributes: [:value, :currency_id],
                                    advance_amount_attributes: [:value, :currency_id],
                                    freight_amount_attributes: [:value, :currency_id],
                                    invoice_attachments_attributes: [:attached_file, :description],
                                    invoice_items_attributes: [:id, :remove_line_item, :description, :item_info, :category_id, :hsn_sac, :quantity, :rate, :discount, :tax, :inventory_line_item_id, custom_fields: []],
                                    invoice_attachments: [],
                                    reminders: [])
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :mobile_number, :description, :gst, :pan, :create_virtual_account,
                                     addresses_attributes: [:line_1, :line_2, :city, :state_id, :name, :pin_code, :id, :default, :address_name],
                                     virtual_bank_accounts_attributes: [:default_account, :name],
                                     customer_attachments_attributes: [:attached_file, :note])
  end

  def calculate_tax_and_discounts
    InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.invoice_parameters, nil, self.invoice)
  end

  def recalculate_totals
    InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.invoice_parameters, nil, self.invoice)
    self.invoice.save
  end

  def set_custom_fields(save, line_item, custom_fields)
    custom_fields = {custom_fields: custom_fields}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(line_item, FieldParentType.id_for(:invoice_line_item), custom_fields)
  end

end