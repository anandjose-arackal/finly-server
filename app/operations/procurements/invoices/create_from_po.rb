class Procurements::Invoices::CreateFromPO < Procurements::Invoices::Base

  attr_accessor :procurement, :purchase_order, :invoice_params, :invoice, :po_revision

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:procurements, :invoices], :validate, self)
        }
    }
  end

  def init
    id = params[:id] || params[:procurement_id]
    self.procurement = user.company.procurements.find_by(id: id)
    self.purchase_order = self.procurement.purchase_order
    self.po_revision = self.procurement.po_revisions.find_by(id: params[:po_id])
    if po_revision.present?
      self.purchase_order = self.po_revision
    end
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

    self.invoice.company_id = user.company.id
    if self.invoice.save
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.invoice_params, nil, self.invoice)
      self.invoice.save


      status_tag = StatusTag.find_by(id: StatusTag.id_for(:invoice_received))
      unless procurement.status_tags.include? status_tag
        procurement.status_tags << status_tag
      end

      # Create Trail for it
      invoice.trails.create action_user: user,
                                   action_id: TrailAction.id_for(:create)
    else
      add_message :error, self.invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice created successfully"
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
          comment: item.comment,
          inventory_line_item_id: item.inventory_line_item_id,
          tax_rate_id: item.tax_rate_id
      }
    end
    invoice_params = {
      vendor_id: self.purchase_order.vendor_id,
      invoice_status_id: ::InwardInvoiceStatus.id_for(:open),
      created_by_user_id: user.id,
      invoice_type_id: ::InwardInvoiceType.id_for(:tax_invoice),
      payment_term_id: self.purchase_order.payment_term_id,
      due_date: self.purchase_order.delivery_date,
      receiving_account: receiving_account,
      gst_type_id: self.purchase_order.gst_type_id,
      location_id: self.purchase_order.location_id,
      delivery_location_id: self.purchase_order.delivery_location_id,
      billing_address: self.purchase_order.billing_address,
      shipping_address: self.purchase_order.shipping_address,
      department_id: self.purchase_order.department_id,
      sub_department_id: self.purchase_order.sub_department_id,
      cost_center_id: self.purchase_order.cost_center_id,
      invoice_items_attributes: invoice_items_attributes,
      policy_id: self.purchase_order.policy_id
    }
  end
end