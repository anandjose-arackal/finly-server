class Procurements::InwardDocuments::Update < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :procurement, :inward_document_params, :purchase_order, :id_old_attachments,
                :id_current_attachments, :po_revision, :inv_items, :grn_enabled, :grn_disabled, :srn_enabled, :srn_disabled

  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    inward_document_id = params[:id] || params[:inward_document_id]
    self.inward_document = procurement.inward_documents.find_by id: inward_document_id
    self.inward_document_params = inward_document_parameters

    self.purchase_order = self.procurement&.purchase_order

    # if self.procurement.po_revisions.present?
    #   self.po_revision = self.procurement.po_revisions.last
    #   if po_revision.present?
    #     self.purchase_order = self.po_revision
    #   end
    # end
  end

  def validate
    validate_role

    unless self.inward_document.present?
      add_message :error, 'Receipt Note not found'
      return
    end
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement, cannot create Receipt Note'
      return
    end

    if self.inward_document_params[:delivery_date].blank?
      add_message :error, "Please add the delivery date for this Receipt Note."
      return
    end

    valid_date = Date.parse(self.inward_document_params[:delivery_date]) rescue false

    unless valid_date
      add_message :error, "Incorrect delivery date supplied."
      return
    end

    unless valid_date <= Date.today
      add_message :error, "Delivery Date cannot be for a future date."
      return
    end

    unless self.inward_document.id == self.procurement.inward_documents.last.id
      add_message :error, "Cannot update old Receipt Notes"
      return
    end

    if self.purchase_order.voided?
      add_message :error, "The Purchase Order associated with this procurement is voided. No further actions can be taken."
      return
    end

    # if invoice was added after adding a grn, block modification of current grn
    if self.procurement.documents&.first&.class&.name == "Invoice"
      add_message :error, "You have added an Invoice for this Receipt Note. If you want to modify it, delete the invoice."
      return
    end

    inward_document_params[:items_attributes].each do |item|
      inward_document_item = self.inward_document.items.find_by(id: item[:id])

      case inward_document_item.inventory_line_item.product_type_id
      when ProductType.id_for(:goods)
        validations_for_goods(item, inward_document_item)
      when ProductType.id_for(:service)
        validations_for_services(item, inward_document_item)
      end
    end

    # validation for check the item already marked as delivered and generated invoice against it
    if self.procurement.invoices.scope_all_except_voided.present?
      inv_items = self.procurement.invoices.scope_all_except_voided.includes(:items)
      self.inward_document.items.each do |item|

        item_q = inv_items.map { |iv| iv.items.where(purchase_order_item_id: item.purchase_order_item_id) }.flatten
        # if invoice did not have this item billed previously or this item was not fully deliverd, skip this check
        next if item_q.blank? 
        next if item.product_type_id == ProductType.id_for(:service) # for now skipping this check for service items
        next if item.quantity == ( item.previously_delivered || ( item.accepted + item.rejected ))
        # if self.inward_document.items.pluck(:previously_delivered).first < item_q.first.quantity
        if item.previously_delivered < item_q.first.quantity
          add_message :error, 'Items in Receipt Note cannot be reduced as they have already been invoiced'
          break
        end
      end
    end

  end

  def pre_process
    self.id_current_attachments = user.company.procurement_attachments.with_id(inward_document_params[:attachments])

    self.inward_document_params.delete(:attachments)

    self.id_old_attachments = self.inward_document.attachments

    inward_document_params[:items_attributes].each do |item|
      item[:delivered] = (item[:delivered].blank?) ? 0 : item[:delivered]
      item[:accepted] = (item[:accepted].blank?) ? 0 : item[:accepted]
      item[:rejected] = (item[:rejected].blank?) ? 0 : item[:rejected]
      item[:billable_amount] = (item[:billable_amount].blank?) ? 0 : item[:billable_amount]
    end
  end

  def process
    self.inward_document.assign_attributes(inward_document_params)
    # Set count for items of purchase order
    # set_purchase_order_items
    if inward_document.valid?
      # Keep track of delivered items in procurement items
      inward_document.items.each do |item|
        case item.inventory_line_item.product_type_id
        when ProductType.id_for(:goods)
          po_item = update_purchase_order_item(item)
          update_accepting_item_amount(item)
        when ProductType.id_for(:service)
          po_item = update_service_item(item)
        end

        # item.update(previously_delivered: po_item.accepted)
      end

      # purchase_order.save

      inward_document.save

      # create trail
      inward_document.trails.create action_user_id: user.id,
                                    action_id: ::TrailAction.id_for(:update)

    else
      add_message :error, inward_document.errors.full_messages
      return
    end

    self.id_old_attachments.update_all(procurement_document_id: nil, procurement_document_type: nil)

    self.id_current_attachments.update_all(procurement_document_id: inward_document.id, procurement_document_type: inward_document.class.name)
  end

  def post_process
    # Update Status Tags for Procurement
    #   Find if all items are shipped
    if all_items_shipped?(self.purchase_order)
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:receiving_shipment))
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:shipment_received))
      self.procurement.status_tags.delete(old_status_tag)
      self.procurement.status_tags << status_tag
      # self.purchase_order.update(purchase_order_status_id: PurchaseOrderStatus.id_for(:closed))
      params[:purchase_order_id] = self.purchase_order.id
      Procurements::PurchaseOrders::Close.(current_user, params) if all_items_accepted?(self.purchase_order)
    else
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:receiving_shipment))
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:shipment_received))
      self.procurement.status_tags.delete(old_status_tag)
      unless self.procurement.status_tags.include? status_tag
        self.procurement.status_tags << status_tag
      end

    end

    add_message :success, 'Successfully updated Receipt Note'
  end

  private

  def inward_document_parameters
    params.require(:inward_document).permit(:id, :doc_number, :override_doc_number, :delivery_date,
                                            items_attributes: [:id, :delivered, :accepted, :rejected, :comment, :billable_amount],
                                            attachments: []
    )

  end

  def update_purchase_order_item(item)
    purchase_order_item = self.purchase_order.items.find_by id: item.purchase_order_item_id

    # accepted = purchase_order_item.accepted
    # rejected = purchase_order_item.rejected
    # delivered = purchase_order_item.delivered

    # if item.changes.present?

    #   if item.changes[:accepted].present?
    #     # Why the f*k was it like this before?
    #     # donkey

    #     # accepted = (accepted - item.changes[:delivered][0]) + item.changes[:delivered][1]
    #     accepted = (accepted - item.changes[:accepted][0]) + item.changes[:accepted][1]
    #   end

    #   if item.changes[:delivered].present?
    #     # delivered = (delivered - item.changes[:accepted][0]) + item.changes[:accepted][1]
    #     delivered = (delivered - item.changes[:delivered][0]) + item.changes[:delivered][1]
    #   end

    #   if item.changes[:rejected].present?
    #     rejected = (rejected.to_f - item.changes[:rejected][0].to_f) + item.changes[:rejected][1].to_f
    #   end
    # end

    other_receipt_notes = self.procurement.inward_documents.where.not(id: self.inward_document.id)
    items = other_receipt_notes.joins(:items).select('inward_document_items.accepted, inward_document_items.delivered, inward_document_items.rejected, inward_document_items.purchase_order_item_id as poi_id')
    previously_accepted = items.collect {|ii| ii if ii.poi_id == purchase_order_item.id}.compact.pluck(:accepted).sum.to_f
    previously_rejected = items.collect {|ii| ii if ii.poi_id == purchase_order_item.id}.compact.pluck(:rejected).sum.to_f
    previously_delivered = items.collect {|ii| ii if ii.poi_id == purchase_order_item.id}.compact.pluck(:delivered).sum.to_f

    accepted = previously_accepted + item.accepted
    rejected = previously_accepted + item.rejected
    delivered = previously_accepted + item.delivered

    po_item_params = {
      accepted: accepted,
      rejected: rejected,
      delivered: delivered
    }

    purchase_order_item.assign_attributes(po_item_params)
    purchase_order_item.save

    purchase_order_item

  end

  def update_service_item(item)
    purchase_order_item = self.purchase_order.items.find_by id: item.purchase_order_item_id

    # previously_billed_amount = purchase_order_item.previously_billed_amount
    # if item.changes[:billable_amount].present?
    #   # previously_billed_amount = (previously_billed_amount - item.changes[:billable_amount][0]) + item.billable_amount[1]
    #   previously_billed_amount = previously_billed_amount + (item.changes[:billable_amount][1] - item.changes[:billable_amount][0])
    # end
    # purchase_order_item.assign_attributes(previously_billed_amount: previously_billed_amount)

    other_receipt_notes = self.procurement.inward_documents.where.not(id: self.inward_document.id)
    previously_billed_amount = other_receipt_notes.joins(:items).select('inward_document_items.billable_amount, inward_document_items.purchase_order_item_id as poi_id').collect {|ii| ii if ii.poi_id == purchase_order_item.id}.compact.pluck(:billable_amount).sum.to_f
    billable_amount = previously_billed_amount + item.billable_amount.to_f
    
    purchase_order_item.assign_attributes(previously_billed_amount: billable_amount)

    purchase_order_item.save

    purchase_order_item
  end

  def update_accepting_item_amount(item)
    amount = item.per_unit_price * item.accepted rescue nil
    if amount.present?
      if item.accepting_item_amount_id.present?
        item.accepting_item_amount.update_column('value', amount)
      else
        item.create_accepting_item_amount(currency_id: 1, value: amount)
      end
    end
  end

  def validations_for_goods(item, inward_document_item)
    delivered = item[:delivered] || 0
    accepted = item[:accepted] || 0
    rejected = item[:rejected] || 0

    if (delivered.to_f < 0 || accepted.to_f < 0 || rejected.to_f < 0)
      add_message :error, "Negative quantity entered for #{inward_document_item.description}"
      # break
      return
    end


    remaining = (inward_document_item.quantity.to_f - inward_document_item.previously_delivered.to_f).round(2) # do not remove the round, it would screw up the floating point arthematic. computer bug, loses precision. nothing i can do.

    if  remaining < delivered.to_f
      add_message :error, "For item - #{inward_document_item.description}, you can enter atmost what is remaining to be delivered, i.e, #{remaining} units"
      # break
      return
    end

    if delivered.to_f > inward_document_item.quantity.to_f
      add_message :error, "For item - #{inward_document_item.description}, delivered quantity cannot be more than the requested quantity"
      # break
      return
    end


    unless delivered.to_f == (accepted.to_f + rejected.to_f).round(2)
      add_message :error, "For item - #{inward_document_item.description}, accepted & rejected quantity does not match with delivered quantity"
      # break
      return
    end

    # comment this out for now, this used to handle a case where quantity for goods was too low,
    # that applying a discount on it would take it to negative
    # 
    # po_item = inward_document_item.purchase_order_item
    # invoice_item_amount = accepted.to_f * po_item.rate.to_f
    # rate = 0
    # discount_amount = 0

    # case po_item.purchase_order.discount_type_id
    #   # i.e. discount is given as a rate
    #   when 1
    #     rate = po_item.discount
    #     discount_amount = (item.discount.to_f * invoice_item_amount.to_f)/100
    #   when 2
    #     rate = ((po_item.discount.to_f / invoice_item_amount) * 100).round(2) rescue 0
    #     discount_amount = (rate.to_f * invoice_item_amount.to_f)/100
    #   else
    #     rate = po_item.discount
    #     discount_amount = (po_item.discount.to_f * invoice_item_amount.to_f)/100
    # end

    # gross_amount = invoice_item_amount - discount_amount

    # if (gross_amount < 0) or (rate > 100)
    #   add_message :error, "Accepted quantity is too low."
    #   return
    # end

  end

  def validations_for_services(item, inward_document_item)
    billable_amount = item[:billable_amount] || 0

    if billable_amount.to_f < 0
      add_message :error, "Negative billable amount entered for #{inward_document_item.description}"
      return
    end

    if (billable_amount.to_f + inward_document_item.previously_billed_amount.to_f) > (inward_document_item.order_amount.to_f + 1)
      add_message :error, "For item - #{inward_document_item.description}, billable amount has exceeded the order amount"
      return
    end

  end



  def all_items_shipped?(po)
    configuration = user.company.feature_subscription

    self.grn_enabled = configuration.grn_enabled == true
    self.grn_disabled = configuration.grn_enabled == false

    self.srn_enabled = configuration.srn_enabled == true
    self.srn_disabled = configuration.srn_enabled == false

    shipped = true

    if self.grn_enabled && self.srn_disabled
      po.items.each do |item|
        next if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
        unless item.quantity == item.accepted
          shipped = false
          break
        end
      end
    elsif self.grn_disabled && self.srn_enabled
      po.items.each do |item|
        next if ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
        unless item.previously_billed_amount.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
          shipped = false
          break
        end
      end
    elsif self.grn_enabled && self.srn_enabled
      po.items.each do |item|
        case item.inventory_line_item.product_type_id
        when ProductType.id_for(:goods)
          unless item.quantity == item.accepted
            shipped = false
            break
          end
        when ProductType.id_for(:service)
          unless item.previously_billed_amount.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
            shipped = false
            break
          end
        end
      end
    end
    shipped
  end

  def all_items_accepted?(po)
    configuration = user.company.feature_subscription

    self.grn_enabled = configuration.grn_enabled == true
    self.grn_disabled = configuration.grn_enabled == false

    self.srn_enabled = configuration.srn_enabled == true
    self.srn_disabled = configuration.srn_enabled == false

    shipped = true

    if self.grn_enabled && self.srn_disabled
      po.items.each do |item|
        next if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
        unless item.quantity == (item.accepted + 0)
          shipped = false
          break
        end
      end
    elsif self.grn_disabled && self.srn_enabled
      po.items.each do |item|
        next if ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
        unless item.previously_billed_amount.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
          shipped = false
          break
        end
      end
    elsif self.grn_enabled && self.srn_enabled
      po.items.each do |item|
        case item.inventory_line_item.product_type_id
        when ProductType.id_for(:service)
          unless item.previously_billed_amount.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
            shipped = false
            break
          end
        when ProductType.id_for(:goods)
          unless item.quantity == (item.accepted + 0)
            shipped = false
            break
          end
        end
      end
    end
    shipped
  end

  def validate_role
    unless user.is_goods_receiver? || user.vendor_payments_admin?
      add_message :error, 'You are not allowed to create this document'
      return
    end
  end

end