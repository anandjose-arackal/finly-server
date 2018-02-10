# once saved, except for the invoice number, all other details can be changed for this invoice
class Invoicing::Invoice::Update < Invoicing::Invoice::Base

  attr_accessor :invoice_parameters, :invoice

  def init
    id = params[:id] || params[:invoice_id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: id)
    self.invoice_parameters = invoice_params
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    unless self.invoice.editable?
      add_message :error, "This invoice cannot be edited"
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
  end

  def process
    # assign the attributes for this particular invoice first
    self.invoice.assign_attributes(self.invoice_parameters)
    # calculate the tax and discounts that need to be done for this particular invoice
    # and store it in the invoice object for further calculation
    calculate_tax_and_discounts

    unless self.invoice.save
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice updated!"
  end

  private

  def calculate_tax_and_discounts
    InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.invoice_parameters, nil, self.invoice)
  end
end