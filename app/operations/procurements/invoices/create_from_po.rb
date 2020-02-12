class Procurements::Invoices::CreateFromPO < Procurements::Invoices::Base

  attr_accessor :procurement, :purchase_order, :invoice_params, :invoice, :po_revision, :previous_invoices, :advance,
                :po_advance, :po_prev_adjusted_advance, :po_adjusted_advance, :last_invoice, :proforma_advance, :custom_fields, :total_adjusted_advance,
                :grn_enabled, :grn_disabled, :srn_enabled, :srn_disabled


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
      self.po_revision = self.procurement.po_revisions.last
      if po_revision.present?
        self.purchase_order = self.po_revision
      end
    end

    self.previous_invoices = (self.procurement.invoices.scope_all_except_voided.present?) ? self.procurement.invoices.scope_all_except_voided.includes(:invoice_items) : nil

    self.invoice_params = set_invoice_parameters

    self.custom_fields = params&.dig(:custom_fields) || params&.dig(:invoice, :custom_fields)

  end

  def validate
    return unless user_role_based_validation
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

  def pre_process
    
  end

  def process
    self.invoice = self.procurement.invoices.build(self.invoice_params)
    
    self.invoice.company_id = user.company.id
    
    validate_custom_fields_invoice
    return if has_errors?
    
    if self.invoice.save
      InvoiceLineItemsCalculationUtils.new.calculate_tax_and_discounts(self.invoice_params, nil, self.invoice)
      self.invoice.save

      if self.advance.present? && (params[:document_type].blank? && params[:document_type] != 'proforma_invoice')
        if self.po_adjusted_advance.value.zero? || self.po_adjusted_advance_id.blank?
          calculcate_po_adjusted_advance
        end
      end

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

    receiving_account = self.purchase_order&.bank_account || self.purchase_order.vendor&.bank_accounts&.first # todo - change this later to the one selected at the time of initiating payment. CHANGED.

    configuration = user.company.feature_subscription

    self.grn_enabled = configuration.grn_enabled == true
    self.grn_disabled = configuration.grn_enabled == false

    self.srn_enabled = configuration.srn_enabled == true
    self.srn_disabled = configuration.srn_enabled == false

    if self.grn_enabled && self.srn_disabled
      invoice_items_attributes =  create_grn
    elsif self.grn_disabled && self.srn_enabled
      invoice_items_attributes =  create_srn
    elsif self.grn_enabled && self.srn_enabled
      invoice_items_attributes =  create_grn_and_srn
    else
      invoice_items_attributes =  create_without_grn_and_srn
    end

    if (invoice_items_attributes.pluck(:quantity).sum == 0) then add_message :error, "Invoice can't be created. Either all items are billed or you need to add a Receipt Note first." end
    

    if self.advance.present?

      # for the new invoice where they want to adjust the advance,
      # in prev adjusted amount, we store the sum of last invoices prev adjusted and its current adjusted advance
      # this way the user knows how much was paid and how much he has to adjust in new invoice
      if self.previous_invoices.present?
         # if last_invoice.po_prev_adjusted_advance == last_invoice.po_advance
        self.last_invoice = self.previous_invoices.last
        self.total_adjusted_advance = self.last_invoice.po_prev_adjusted_advance.to_i + self.last_invoice.po_adjusted_advance&.value&.to_i
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
      gstin_location_id: self.purchase_order.gstin_location_id,
      cost_allocation_items: self.purchase_order.cost_allocation_items,
      po_number: self.purchase_order.po_number,
      discount_type_id: self.purchase_order.discount_type_id
    }

    if self.advance.present?
        invoice_params[:po_advance] = self.po_advance
        invoice_params[:po_prev_adjusted_advance] = self.po_prev_adjusted_advance
        invoice_params[:po_adjusted_advance] = self.po_adjusted_advance
    end

    return invoice_params
  end

  def validate_custom_fields_invoice
    set_fields = set_custom_fields_invoice self.invoice, self.custom_fields, false
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    # valid = CustomField::Validate.(self.invoice)
    # unless valid.success?
    #   add_message :error, valid.messages[:error]
    #   return
    # end
  end

  def set_custom_fields_invoice(invoice, data, save)
    custom_fields = {custom_fields: data}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(invoice, FieldParentType.id_for(:invoice), custom_fields)
  end



  # default configuration
  # considers goods accepted and service quantity
  def create_grn
    invoice_items_attributes = []
    self.purchase_order.items.each do |item|
      real_q = 0
      if self.previous_invoices.present?
        item_in_invoice = self.previous_invoices.first.invoice_items.pluck(:purchase_order_item_id).include? item.id
        # This query does not hit the DB.
        # we sum previous invoices line item
        # if that turns out to be zero, invoice for this item is not created
        # awesome stuff.
        it_cal = self.previous_invoices.map {|p21| p21.invoice_items.map{|ili| ili.quantity if ili.purchase_order_item_id == item.id } }.flatten.compact.sum
        # if the item was in previous invoice
        # but the quantity was zero, that is, it was not billed
        # and most importantly,
        # item quantity billed in previous invoices were all delivered and accepted
        # then skip
        # we do this coz there is a chance that user would not pay for all the quantity delivered in one invoice
        if it_cal == 0 && item_in_invoice && it_cal.to_f == item.accepted.to_f && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          next
        else
          # i forgot what i did here, but this is important.
          real_q = item.accepted.to_f - it_cal.to_f
          next if real_q <= 0  && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
            real_q = item.quantity - it_cal
            next if real_q <= 0
          end
        end
      else
        # vendor is billed only for what he delivered and what the user accepted
        real_q = item.accepted.to_f
        next if real_q == 0 && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
        if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
          real_q = item.quantity
        end
      end
      data = {
          tax: item.tax,
          discount: item.discount,
          unit_of_measurement: item.unit_of_measurement,
          rate: item.rate,
          quantity: real_q,
          hsn_sac: item.hsn_sac,
          description: item.description,
          gst_type_id: self.purchase_order.gst_type_id,
          comment: item.comment,
          inventory_line_item_id: item.inventory_line_item_id,
          department_id: item.department_id,
          cost_center_id: item.cost_center_id,
          tax_rate_id: item.tax_rate_id,
          category_id: item.category_id,
          cgst: item.cgst,
          sgst: item.sgst,
          igst: item.igst,
          purchase_order_item_id: item.id #,
          # billable_amount_attributes: {
          #     value: get_billable_amount(item),
          #     currency_id: 1
          # }
      }
      if item.inventory_line_item.service?
        data[:billable_amount_attributes] = {value: item.taxable_amount&.value.to_f, currency_id: 1}
      end
      invoice_items_attributes << data
    end
    invoice_items_attributes
  end



  # considers goods quantity and service billable amount
  def create_srn
    invoice_items_attributes = []
    srn_item = self.procurement.inward_documents.joins(:items).select('inward_document_items.billable_amount, inward_document_items.purchase_order_item_id as poi_id')
    self.purchase_order.items.each do |item|
      previously_billed_amount = srn_item.collect {|ii| ii if ii.poi_id == item.id}.compact.pluck(:billable_amount).sum.to_f
      real_q = 0
      real_amount = 0
      if self.previous_invoices.present?
        item_in_invoice = self.previous_invoices.first.invoice_items.pluck(:purchase_order_item_id).include? item.id
        # This query does not hit the DB.
        # we sum previous invoices line item
        # if that turns out to be zero, invoice for this item is not created
        # awesome stuff.
        it_cal = self.previous_invoices.map {|p21| p21.invoice_items.map{|ili| ili.quantity if ili.purchase_order_item_id == item.id } }.flatten.compact.sum
        # if the item was in previous invoice
        # but the quantity was zero, that is, it was not billed
        # and most importantly,
        # item quantity billed in previous invoices were all delivered and accepted
        # then skip
        # we do this coz there is a chance that user would not pay for all the quantity delivered in one invoice
        if it_cal == 0 && item_in_invoice && it_cal.to_f == item.quantity.to_f && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          next
        else
          # i forgot what i did here, but this is important.
          real_q = item.quantity.to_f - it_cal.to_f
          next if real_q <= 0  && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
            # here we sum billable amount for all service items in previous invoices
            # if they are not the same, we create the invoice, else
            # we skip it.
            bill_cal = self.previous_invoices.map {|p21| p21.invoice_items.map{|ili| ili.billable_amount&.value if ili.purchase_order_item_id == item.id } }.flatten.compact.sum
            # next if real_q <= 0
            next if bill_cal.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
            real_q = item.quantity
            real_amount = previously_billed_amount - bill_cal
            next if real_amount <=0
          end
        end
      else
        # vendor is billed only for what he delivered and what the user accepted
        real_q = item.quantity.to_f
        next if real_q == 0 && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
        if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
          next unless previously_billed_amount > 0
          real_q = item.quantity
          real_amount = previously_billed_amount
        end
      end
      invoice_items_attributes << {
          tax: item.tax,
          discount: item.discount,
          unit_of_measurement: item.unit_of_measurement,
          rate: item.rate,
          quantity: real_q,
          hsn_sac: item.hsn_sac,
          description: item.description,
          gst_type_id: self.purchase_order.gst_type_id,
          comment: item.comment,
          inventory_line_item_id: item.inventory_line_item_id,
          department_id: item.department_id,
          cost_center_id: item.cost_center_id,
          tax_rate_id: item.tax_rate_id,
          category_id: item.category_id,
          cgst: item.cgst,
          sgst: item.sgst,
          igst: item.igst,
          purchase_order_item_id: item.id,
          billable_amount_attributes: {
              value: real_amount,
              currency_id: 1
          }
      }
    end
    invoice_items_attributes
  end


  # takes into account goods accepted and service billable amount
  def create_grn_and_srn
    invoice_items_attributes = []
    rn_item = self.procurement.inward_documents.joins(:items).select('inward_document_items.billable_amount, inward_document_items.purchase_order_item_id as poi_id, inward_document_items.accepted')
    self.purchase_order.items.each do |item|
      previously_billed_amount = rn_item.collect {|ii| ii if ii.poi_id == item.id}.compact.pluck(:billable_amount).sum.to_f
      accepted = rn_item.collect {|ii| ii if ii.poi_id == item.id}.compact.pluck(:accepted).sum.to_f
      real_q = 0
      real_amount = 0
      if self.previous_invoices.present?
        item_in_invoice = self.previous_invoices.first.invoice_items.pluck(:purchase_order_item_id).include? item.id
        # This query does not hit the DB.
        # we sum previous invoices line item
        # if that turns out to be zero, invoice for this item is not created
        # awesome stuff.
        it_cal = self.previous_invoices.map {|p21| p21.invoice_items.map{|ili| ili.quantity if ili.purchase_order_item_id == item.id } }.flatten.compact.sum
        # if the item was in previous invoice
        # but the quantity was zero, that is, it was not billed
        # and most importantly,
        # item quantity billed in previous invoices were all delivered and accepted
        # then skip
        # we do this coz there is a chance that user would not pay for all the quantity delivered in one invoice
        if it_cal == 0 && item_in_invoice && it_cal.to_f == accepted.to_f && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          next
        else
          # i forgot what i did here, but this is important.
          real_q = accepted.to_f - it_cal.to_f
          next if real_q <= 0  && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
            # here we sum billable amount for all service items in previous invoices
            # if they are not the same, we create the invoice, else
            # we skip it.
            bill_cal = self.previous_invoices.map {|p21| p21.invoice_items.map{|ili| ili.billable_amount&.value if ili.purchase_order_item_id == item.id } }.flatten.compact.sum
            # next if real_q <= 0
            next if bill_cal.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
            real_q = item.quantity
            real_amount = previously_billed_amount - bill_cal
            next if real_amount <=0
          end
        end
      else
        # vendor is billed only for what he delivered and what the user accepted
        real_q = accepted.to_f
        next if real_q == 0 && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
        if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
          next unless previously_billed_amount > 0
          real_q = item.quantity
          real_amount = previously_billed_amount
        end
      end
      invoice_items_attributes << {
          tax: item.tax,
          discount: item.discount,
          unit_of_measurement: item.unit_of_measurement,
          rate: item.rate,
          quantity: real_q,
          hsn_sac: item.hsn_sac,
          description: item.description,
          gst_type_id: self.purchase_order.gst_type_id,
          comment: item.comment,
          inventory_line_item_id: item.inventory_line_item_id,
          department_id: item.department_id,
          cost_center_id: item.cost_center_id,
          tax_rate_id: item.tax_rate_id,
          category_id: item.category_id,
          cgst: item.cgst,
          sgst: item.sgst,
          igst: item.igst,
          purchase_order_item_id: item.id,
          billable_amount_attributes: {
              value: real_amount,
              currency_id: 1
          }
      }
    end
    invoice_items_attributes
  end



  # only takes into account quantity for both goods and service
  def create_without_grn_and_srn
    invoice_items_attributes = []
    self.purchase_order.items.each do |item|
      real_q = 0
      if self.previous_invoices.present?
        item_in_invoice = self.previous_invoices.first.invoice_items.pluck(:purchase_order_item_id).include? item.id
        # This query does not hit the DB.
        # we sum previous invoices line item
        # if that turns out to be zero, invoice for this item is not created
        # awesome stuff.
        it_cal = self.previous_invoices.map {|p21| p21.invoice_items.map{|ili| ili.quantity if ili.purchase_order_item_id == item.id } }.flatten.compact.sum
        # if the item was in previous invoice
        # but the quantity was zero, that is, it was not billed
        # and most importantly,
        # item quantity billed in previous invoices were all delivered and accepted
        # then skip
        # we do this coz there is a chance that user would not pay for all the quantity delivered in one invoice
        if it_cal == 0 && item_in_invoice && it_cal.to_f == item.quantity.to_f && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          next
        else
          # i forgot what i did here, but this is important.
          real_q = item.quantity.to_f - it_cal.to_f
          next if real_q <= 0  && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
          if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
            real_q = item.quantity - it_cal
            next if real_q <= 0
          end
        end
      else
        # vendor is billed only for what he delivered and what the user accepted
        real_q = item.quantity.to_f
        next if real_q == 0 && ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
        if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
          real_q = item.quantity
        end
      end
      invoice_items_attributes << {
          tax: item.tax,
          discount: item.discount,
          unit_of_measurement: item.unit_of_measurement,
          rate: item.rate,
          quantity: real_q,
          hsn_sac: item.hsn_sac,
          description: item.description,
          gst_type_id: self.purchase_order.gst_type_id,
          comment: item.comment,
          inventory_line_item_id: item.inventory_line_item_id,
          department_id: item.department_id,
          cost_center_id: item.cost_center_id,
          tax_rate_id: item.tax_rate_id,
          category_id: item.category_id,
          cgst: item.cgst,
          sgst: item.sgst,
          igst: item.igst,
          purchase_order_item_id: item.id,
          billable_amount_attributes: {
              value: item.taxable_amount&.value.to_f,
              currency_id: 1
          }
      }
    end
    invoice_items_attributes
  end




  def calculcate_po_adjusted_advance
    self.total_adjusted_advance = 0
    if self.last_invoice.present?
      self.total_adjusted_advance = self.last_invoice.po_prev_adjusted_advance.to_f + self.last_invoice.po_adjusted_advance&.value&.to_f
    end
    allowed_current_adjustment = self.po_advance - self.total_adjusted_advance rescue nil
    bal_due_amount = nil
    current_adjustment = nil
    # Current allowed adjustment should be present and should not be previously exhausted
    if allowed_current_adjustment.present? && !allowed_current_adjustment.zero?
      case
        when self.invoice&.balance_due&.value.present? && self.invoice&.balance_due&.value >= allowed_current_adjustment
        # Substract PO advance amount from balance due amount
        bal_due_amount = self.invoice&.balance_due&.value - allowed_current_adjustment
        current_adjustment = allowed_current_adjustment
        when self.invoice&.balance_due&.value.present? &&  self.invoice&.balance_due&.value < allowed_current_adjustment
         current_adjustment = self.invoice&.balance_due&.value
         bal_due_amount = 0
      end
      set_advance_amount_required
    end
    unless bal_due_amount.blank?
      self.invoice.balance_due.update(value: bal_due_amount)
    end

    if current_adjustment.present?
      self.invoice.po_adjusted_advance.update(value: current_adjustment)
      invoice_params[:po_adjusted_advance] = self.po_adjusted_advance
    end

  end

  def set_advance_amount_required
    self.invoice.update(advance_amount_required: true)
  end

  def user_role_based_validation
    # Invoice created from PO will have same policy, hence check if that user has po_invoice_initiator role for that policy
    is_po_invoice_initiator = self.purchase_order.policy.policy_user_roles.with_user_id(user.id).with_role_id(UserRole.id_for(:po_invoice_initiator)).present? rescue false
    
    unless is_po_invoice_initiator
      add_message :error, "You are not allowed to take this action."
      return
    end
    true
  end


end


