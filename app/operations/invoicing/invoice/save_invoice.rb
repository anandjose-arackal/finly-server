# this checks the invoice for all validations and eventually saves the invoice which can now be sent to the customer
class Invoicing::Invoice::SaveInvoice < Invoicing::Invoice::Base

  attr_accessor :invoice, :invoice_parameters, :invoice_number, :invoice_current_attachments, :invoice_old_attachments

  def init
    id = params[:id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: id)
    self.invoice_parameters = invoice_params
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    if self.invoice.cancelled? || self.invoice.partially_paid? || self.invoice.closed?
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
    prefix = user.company.invoice_number_config.prefix
    sequence = self.invoice_number&.gsub(prefix, '')
    self.invoice_parameters[:prefix] = prefix
    self.invoice_parameters[:sequence_start] = sequence

    # Extracting invoice attachments
    self.invoice_current_attachments = user.company.outward_invoice_attachments.with_id(invoice_parameters[:invoice_attachments])

    # Remove :invoice_attachments from parameters
    self.invoice_parameters.delete(:invoice_attachments)

    # Old Attachments
    self.invoice_old_attachments = invoice.attachments

  end

  def process
    # assign the attributes for this particular invoice first
    self.invoice.assign_attributes(self.invoice_parameters)
    # calculate the tax and discounts that need to be done for this particular invoice
    # and store it in the invoice object for further calculation
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

    if self.invoice.update(invoice_status_id: OutwardInvoiceStatus.id_for(:saved), is_deleted: false)
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

  private

  def invoice_params
    params.require(:invoice).permit(:gst_type_id, :tds, :tds_type_id, :category_id, :customer_id,
                                    :tax_type_id, :date, :discount_type_id, :due_date, :memo, :customer_memo, :payment_term_id,
                                    :invoice_number, :inclusive_of_taxes, :billing_address, :shipping_address, :override_invoice_number,
                                    :email, :mobile_number, :virtual_account_id, :roundoff_amount, :roundoff_total_enabled,
                                    original_amount_attributes: [:value, :currency_id],
                                    advance_amount_attributes: [:value, :currency_id],
                                    freight_amount_attributes: [:value, :currency_id],
                                    invoice_attachments_attributes: [:attached_file, :description],
                                    invoice_items_attributes: [:id, :remove_line_item, :description, :category_id, :hsn_sac, :quantity, :rate, :discount, :tax, :inventory_line_item_id],
                                    invoice_attachments: [])
  end

  def customer_params
    params.require(:customer).permit(:gst)
  end

  def calculate_tax_and_discounts
    InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.invoice_parameters, nil, self.invoice)
  end

  def recalculate_totals
    InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.invoice_parameters, nil, self.invoice)
    self.invoice.save
  end

end