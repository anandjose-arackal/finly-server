class Procurements::InwardDocuments::Update < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :procurement, :inward_document_params, :purchase_order, :id_old_attachments,
                :id_current_attachments, :po_revision
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    inward_document_id = params[:id] || params[:inward_document_id]
    self.inward_document = procurement.inward_documents.find_by id: inward_document_id
    self.inward_document_params = inward_document_parameters
    self.purchase_order = self.procurement&.purchase_order

    if self.procurement.po_revisions.present?
      # self.po_revision = self.procurement.po_revisions.find_by(id: params[:po_id])
      self.po_revision = self.procurement.po_revisions.last
      if po_revision.present?
        self.purchase_order = self.po_revision
      end
    end
  end

  def validate
    unless self.inward_document.present?
      add_message :error, 'Inward Document not found'
      return
    end
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement, cannot create inward document'
      return
    end

    unless self.inward_document.id == self.procurement.inward_documents.last.id
      add_message :error, "Cant update old GRNs"
      return
    end

    inward_document_params[:items_attributes].each do |item|
      delivered = item[:delivered] || 0
      accepted = item[:accepted] || 0
      rejected = item[:rejected] || 0

      po_items = self.inward_document.items.find_by(id: item[:id])


      if (po_items.quantity.to_f - po_items.previously_delivered.to_f) < delivered.to_f
        add_message :error, "Previously deliverd cant be less than what is delivered now."
        break
      end 

      if delivered.to_f > po_items.quantity.to_f
        add_message :error, "Now Delivering cannot be more than the Requested Quantity"
        break
      end


      unless delivered.to_f == accepted.to_f + rejected.to_f
        add_message :error, "Accepted & Rejected quantity does't match with delivered quantity"
        break
      end
    end

  end

  def pre_process
    self.id_current_attachments = user.company.procurement_attachments.with_id(inward_document_params[:attachments])

    self.inward_document_params.delete(:attachments)

    self.id_old_attachments = self.inward_document.attachments
  end

  def process

    self.inward_document.assign_attributes(inward_document_params)
    # Set count for items of purchase order
    # set_purchase_order_items
    if inward_document.valid?
      # Keep track of delivered items in procurement items
      inward_document.items.each do |item|
        po_item = update_purchase_order_item(item)

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
    if self.purchase_order.all_items_shipped?
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:receiving_shipment))
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:shipment_received))
      self.procurement.status_tags.delete(old_status_tag)
      self.procurement.status_tags << status_tag
      # self.purchase_order.update(purchase_order_status_id: PurchaseOrderStatus.id_for(:closed))
      params[:purchase_order_id] = self.purchase_order.id
      Procurements::PurchaseOrders::Close.(current_user, params) if self.purchase_order.all_items_accepted?
    else
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:receiving_shipment))
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:shipment_received))
      self.procurement.status_tags.delete(old_status_tag)
      unless self.procurement.status_tags.include? status_tag
        self.procurement.status_tags << status_tag
      end

    end

    add_message :success, 'Successfully updated Inward Document'
  end

  private

  def inward_document_parameters
    params.require(:inward_document).permit(:id, :doc_number, :override_doc_number, :delivery_date,
                                            items_attributes: [:id, :delivered, :accepted, :rejected, :comment],
                                            attachments: []
    )

  end

  def update_purchase_order_item(item)
    purchase_order_item = self.purchase_order.items.find_by id: item.purchase_order_item_id

    accepted = purchase_order_item.accepted
    rejected = purchase_order_item.rejected
    delivered = purchase_order_item.delivered

    if item.changes.present?

      if item.changes[:delivered].present?
        # Why the f*k was it like this before?
        # donkey

        # accepted = (accepted - item.changes[:delivered][0]) + item.changes[:delivered][1]
        accepted = (accepted - item.changes[:accepted][0]) + item.changes[:accepted][1]
      end

      if item.changes[:accepted].present?
        # delivered = (delivered - item.changes[:accepted][0]) + item.changes[:accepted][1]
        delivered = (delivered - item.changes[:delivered][0]) + item.changes[:delivered][1]
      end

      if item.changes[:rejected].present?
        rejected = (rejected - item.changes[:rejected][0]) + item.changes[:rejected][1]
      end
    end

    po_item_params = {
      accepted: accepted,
      rejected: rejected,
      delivered: delivered
    }

    purchase_order_item.assign_attributes(po_item_params)
    purchase_order_item.save

    purchase_order_item

  end

  def set_purchase_order_items
  end

end