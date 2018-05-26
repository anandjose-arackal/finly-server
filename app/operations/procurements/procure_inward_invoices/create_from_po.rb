class Procurements::ProcureInwardInvoices::CreateFromPO < Procurements::ProcureInwardInvoices::Base

  attr_accessor :procurement, :purchase_order, :invoice_params, :invoice

  def init
    id = params[:id] || params[:procurement_id]
    self.procurement = user.company.procurements.find_by(id: id)
    self.purchase_order = self.procurement.purchase_order
    self.invoice_params = set_invoice_parameters
  end

  def validate
    if self.procurement.blank?
      add_message :success, "Procurement not found"
      return
    end

    if self.purchase_order.blank?
      add_message :error, "Purchase order not present"
      return
    end

    if self.invoice_params.blank?
      add_message :error, "Procurement or purchase order not present"
    end
  end

  def process
    self.invoice = self.procurement.invoices.build(self.invoice_params)
    if self.invoice.save
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.invoice_params, nil, self.invoice)
      self.invoice.vendor_id = self.procurement.vendor_id
      self.invoice.save
    else
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice created successfully"
  end

  private

  def set_invoice_parameters
    if self.procurement.blank? || self.purchase_order.blank?
      return nil
    end
    receiving_account = self.purchase_order.vendor&.bank_accounts&.first # todo - change this later to the one selected at the time of initiating payment
    invoice_items_attributes = []
    self.purchase_order.items.each do |item|
      invoice_items_attributes << {
          tax: item.tax,
          discount: item.discount,
          rate: item.rate,
          quantity: item.quantity,
          hsn_sac: item.hsn_sac,
          description: item.description,
          gst_type_id: self.purchase_order.gst_type_id,
      }
    end
    invoice_params = {
      receiving_account: receiving_account,
      gst_type_id: self.purchase_order.gst_type_id,
      invoice_items_attributes: invoice_items_attributes
    }
    invoice_params
  end

end