class Procurements::Invoices::Update < Procurements::Invoices::Base

  attr_accessor :procurement, :purchase_order, :invoice_params, :invoice, :po_revision

  def init
    id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by(id: id)
    self.purchase_order = self.procurement.purchase_order

    invoice_id = params[:id] || params[:invoice_id]
    self.invoice = user.company.invoices.find_by(id: invoice_id)
    self.invoice_params = set_invoice_parameters

    if self.procurement.po_revisions.present?
      # self.po_revision = self.procurement.po_revisions.find_by(id: params[:po_id])
      self.po_revision = self.procurement.po_revisions.last
      if po_revision.present?
        self.purchase_order = self.po_revision
      end
    end

    self.custom_fields = params&.dig(:custom_fields) || params&.dig(:invoice, :custom_fields)
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

    if self.invoice.blank?
      add_message :error, 'Inward Invoice not found'
    end
  end

  def process
    self.invoice.assign_attributes(invoice_params)
    validate_custom_fields_invoice
    return if has_errors?

    if invoice.valid?
      invoice.save
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.invoice_params, nil, self.invoice)
      self.invoice.vendor_id = self.procurement.vendor_id
      self.invoice.save
    else
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice updated successfully"
  end

  def success
    params[:invoice] = self.invoice
    Procurements::Invoices::CreateFromPO::ShowPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::CreateFromPO::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoice

    def init
      self.invoice = params[:invoice]
    end
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

  def validate_custom_fields_invoice
    set_fields = set_custom_fields_invoice self.invoice, self.custom_fields, false
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(self.invoice)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end
  end

  def set_custom_fields_invoice(invoice, data, save)
    custom_fields = {custom_fields: data}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(invoice, FieldParentType.id_for(:invoice), custom_fields)
  end

end