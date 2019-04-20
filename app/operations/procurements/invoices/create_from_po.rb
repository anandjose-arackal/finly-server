class Procurements::Invoices::CreateFromPO < Procurements::Invoices::Base

  attr_accessor :procurement, :purchase_order, :invoice_params, :invoice, :po_revision, :previous_invoices, :advance,
                :po_advance, :po_prev_adjusted_advance, :po_adjusted_advance, :last_invoice, :proforma_advance

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
    if self.procurement.po_revisions.present?
      # self.po_revision = self.procurement.po_revisions.find_by(id: params[:po_id])
      self.po_revision = self.procurement.po_revisions.last
      if po_revision.present?
        self.purchase_order = self.po_revision
      end
    end

    self.previous_invoices = (self.procurement.invoices.present?) ? self.procurement.invoices.includes(:invoice_items) : nil

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

    # if self.previous_invoices.present?
    #   self.last_invoice = self.previous_invoices.last
    #   if self.advance.present? && ( last_invoice.po_prev_adjusted_advance == last_invoice.po_advance )
    #     add_message :error, "Advance amount for the purchase order has already been cleared in previous invoices."
    #   end
    # end

  end

  def pre_process
    
  end

  def process

    self.invoice = self.procurement.invoices.build(self.invoice_params)
    
    self.invoice.company_id = user.company.id
    if self.invoice.save
      if (params[:document_type].present? && params[:document_type] == 'proforma_invoice')
        self.invoice.proforma_invoice_id = self.invoice.id
      end
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

    self.advance = self.purchase_order.advance_amount

    receiving_account = self.purchase_order.vendor&.bank_accounts&.first # todo - change this later to the one selected at the time of initiating payment
    invoice_items_attributes = []

    # The idea is, twofold
    # 1. every new invoice created would have the line item quantity automatically adjusted to what was previously entered and paid against
    # 2. po advance if it exists, new invoice is given the option to adjust it against the balance due for delivered items.

    # ugly, rewrite this later
    self.purchase_order.items.each do |item|

      real_q = 0

    if (params[:document_type].blank? && params[:document_type] != 'proforma_invoice')
      if self.previous_invoices.present?

        item_in_invoice = self.previous_invoices.first.invoice_items.pluck(:inventory_line_item_id).include? item.inventory_line_item_id
        # This query does not hit the DB.
        # we sum previous invoices line item
        # if that turns out to be zero, invoice for this item is not created
        # awesome stuff.
        it_cal = self.previous_invoices.map {|p21| p21.invoice_items.map{|ili| ili.quantity if ili.inventory_line_item_id == item.inventory_line_item_id } }.flatten.compact.sum
        # if the item was in previous invoice
        # but the quantity was zero, that is, it was not billed
        # and most importantly,
        # item quantity billed in previous invoices were all delivered and accepted
        # then skip
        # we do this coz there is a chance that user would not pay for all the quantity delivered in one invoice
        if it_cal == 0 && item_in_invoice && it_cal.to_i == item.accepted.to_i && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          next
        else
          # i forgot what i did here, but this is important.
          real_q = item.accepted.to_i - it_cal.to_i
          next if real_q <= 0  && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
            real_q = item.quantity - it_cal
            next if real_q <= 0
          end
        end
      else
        # vendor is billed only for what he delivered and what the user accepted
        real_q = item.accepted.to_i
        next if real_q == 0 && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
        if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
          real_q = item.quantity
        end
      end
    else
      real_q = item.quantity
    end
      invoice_items_attributes << {
          tax: item.tax,
          discount: item.discount,
          unit_of_measurement: item.unit_of_measurement,
          rate: item.rate,
          # quantity: item.accepted,
          quantity: real_q,
          hsn_sac: item.hsn_sac,
          description: item.description,
          gst_type_id: self.purchase_order.gst_type_id,
          comment: item.comment,
          inventory_line_item_id: item.inventory_line_item_id,
          department_id: item.department_id,
          cost_center_id: item.cost_center_id,
          tax_rate_id: item.tax_rate_id
      }
    end
    
    if (invoice_items_attributes.pluck(:quantity).sum == 0) then add_message :error, "Invoice can't be created. Either all items are billed or you need to add a GRN first." end
    

    if self.advance.present? && (params[:document_type].blank? && params[:document_type] != 'proforma_invoice')

      # for the new invoice where they want to adjust the advance,
      # in prev adjusted amount, we store the sum of last invoices prev adjusted and its current adjusted advance
      # this way the user knows how much was paid and how much he has to adjust in new invoice
      if self.previous_invoices.present?
         # if last_invoice.po_prev_adjusted_advance == last_invoice.po_advance
        self.last_invoice = self.previous_invoices.last
        total_adjusted_advance = self.last_invoice.po_prev_adjusted_advance.to_i + self.last_invoice.po_adjusted_advance&.value&.to_i
        self.po_prev_adjusted_advance = total_adjusted_advance
        self.po_advance = ( self.advance.present? ) ? self.advance.value : nil
        current_adjustment = self.po_advance - total_adjusted_advance
        self.po_adjusted_advance = Amount.new(value: 0, currency_id: 1)
      else
        self.po_prev_adjusted_advance = 0
        self.po_advance = ( self.advance.present? ) ? self.advance.value : nil
        self.po_adjusted_advance = Amount.new(value: 0, currency_id: 1)
      end
    end

    invoice_type = ::InwardInvoiceType.id_for(:tax_invoice)
    if (params[:document_type].present? && params[:document_type] == 'proforma_invoice')
      invoice_type = ::InwardInvoiceType.id_for(:proforma_invoice)
      self.proforma_advance = Amount.new(value: 0, currency_id: 1)
    end

    invoice_params = {
      vendor_id: self.purchase_order.vendor_id,
      invoice_status_id: ::InwardInvoiceStatus.id_for(:open),
      created_by_user_id: user.id,
      invoice_type_id: invoice_type,
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
      policy_id: self.purchase_order.policy_id,
      gstin_location_id: self.purchase_order.gstin_location_id
    }

    if self.advance.present? && (params[:document_type].blank? && params[:document_type] != 'proforma_invoice')
        invoice_params[:po_advance] = self.po_advance
        invoice_params[:po_prev_adjusted_advance] = self.po_prev_adjusted_advance
        invoice_params[:po_adjusted_advance] = self.po_adjusted_advance
    end

    if (params[:document_type].present? && params[:document_type] == 'proforma_invoice')
      invoice_params[:proforma_advance] = self.proforma_advance
    end
    return invoice_params
  end
end


