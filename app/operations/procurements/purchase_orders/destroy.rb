class Procurements::PurchaseOrders::Destroy < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params, :po_available, :po_previous_status

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.procurement = self.purchase_order.procurement

    if self.procurement.po_revisions.present?
      if is_approve?
        self.po_previous_status = PurchaseOrderStatus.id_for(:approved)

      elsif is_auto_approve?
        self.po_previous_status = PurchaseOrderStatus.id_for(:auto_approved)

      elsif is_send_to_vendor?
        self.po_previous_status = PurchaseOrderStatus.id_for(:sent_to_vendor)
      
      elsif is_vendor_confirmed?
        self.po_previous_status = PurchaseOrderStatus.id_for(:vendor_confirmed)
      end
    end
        
        

  end

  def validate
    unless PurchaseOrderStatus.ids_for([:open, :retracted, :rejected]).include? purchase_order.status.id
      add_message :error, "You can't delete purchase order at this state."
    end
  end

  def process
    self.po_available = true
    if self.procurement.po_revisions.present?
      if self.purchase_order.destroy
        add_message :success, "Successfully Deleted Purchase Order."
        return
      end
    else       
      if rollback_purchase_request_items_status && self.procurement.destroy
        self.po_available = false
        add_message :success, "Successfully Deleted Procurement"
      end
    end
  end

  def success
    params[:po_available] = self.po_available
    Procurements::PurchaseOrders::Destroy::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Destroy::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :po_available

    def init
      # Helps to know in frontend if they should redirect to procurement index or simply re-render the same procurement show page
      self.po_available = params[:po_available]
    end
  end

  def post_process
    if po_available
      if self.procurement.po_revisions.reload.present?
        po = self.procurement.reload.po_revisions.last
        # po.purchase_order_status_id = PurchaseOrderStatus.id_for(:sent_to_vendor)
        po.purchase_order_status_id = self.po_previous_status
        update_status(po)
        po.save
      else
        po = self.procurement.reload.purchase_order
        # po.purchase_order_status_id = PurchaseOrderStatus.id_for(:sent_to_vendor)
        po.purchase_order_status_id = self.po_previous_status
        update_status(po)
        po.save
      end
    end
  end

  private

  def update_status(po)
    # will get back to this later
    # po.purchase_order_status_id = PurchaseOrderStatus.id_for(:sent_to_vendor)
    # Update procurement po approved status tags
    # old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_approved))
    # status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_processing))
    # self.procurement.status_tags.delete(old_status_tag)
    # self.procurement.status_tags << status_tag

    # Update procurement send status
    # status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_sent))
    # if self.procurement.status_tags.include? status_tag
      # self.procurement.status_tags.delete(status_tag)
    # end
  end

  def previous_state
    if self.procurement.po_revisions.present? && (self.procurement.po_revisions.count > 1)
      ps = self.procurement.reload.po_revisions[-2].trails.where(action_id: [TrailAction.id_for(:approve), TrailAction.id_for(:auto_approve), TrailAction.id_for(:send_to_vendor), TrailAction.id_for(:vendor_confirmed)])
    else
      ps = self.procurement.reload.purchase_order.trails.where(action_id: [TrailAction.id_for(:approve), TrailAction.id_for(:auto_approve), TrailAction.id_for(:send_to_vendor), TrailAction.id_for(:vendor_confirmed)])
    end
    ps.last.action_id
  end

  def is_approve?(state=false)
    ps_id = previous_state
    state = ( ps_id == TrailAction.id_for(:approve) ) ? true : false
  end

  def is_auto_approve?(state=false)
    ps_id = previous_state
    state = ( ps_id == TrailAction.id_for(:auto_approve) ) ? true : false
  end

  def is_send_to_vendor?(state=false)
    ps_id = previous_state
    state = ( ps_id == TrailAction.id_for(:send_to_vendor) ) ? true : false
  end

  def is_vendor_confirmed?(state=false)
    ps_id = previous_state
    state = ( ps_id == TrailAction.id_for(:vendor_confirmed) ) ? true : false
  end

  def rollback_purchase_request_items_status
    # TODO - take care of item status if pr status changes in future after PR-> PO is created 
    # TODO - Status logic will change once we have PR 'closed'  status in place
    purchase_request_item_ids = self.purchase_order.items.pluck(:purchase_request_item_id).uniq rescue []
    unless purchase_request_item_ids.blank?
      purchase_request_items = PurchaseRequestItem.where(id: purchase_request_item_ids) 
      purchase_request_items.each do |purchase_request_item|
        trail_status = purchase_request_item.trails.where(action_id: [TrailAction.id_for(:approve), TrailAction.id_for(:auto_approve)]).last.action.name
        if trail_status == 'approve'
          status = 'approved'
        elsif trail_status == 'auto_approve'
          status = 'auto_approved'
        end
        purchase_request_item.status_id = PurchaseRequestItemStatus.id_for(status) # Status can be approved/auto-approved
        if purchase_request_item.save && purchase_request_item.status_id.present?
          Trail.create(parent_type: 'PurchaseRequestItem', parent_id: purchase_request_item.id, action_user_id: user.id, action_id: TrailAction.id_for(:po_deleted))
        end
      end
    end
  end

end
