class Procurements::PurchaseOrders::Reopen < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params, :workflow_output

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

    unless user.vendor_payment_admin? || self.purchase_order.document_owner?(user)
      add_message :error, 'You are not authorized to reopen this document. Please contact the initiator of this PO or the admin.'
    end
  end

  def process
    # Using workflow manager to do this task, skipping manual process
    # self.prev_status = self.purchase_order.trails.reverse.find {|t| [TrailAction.id_for(:auto_approve),
    #                                                                   TrailAction.id_for(:approve),
    #                                                                 TrailAction.id_for(:send_to_vendor)].include? t.action_id}

    
    # status = (user.vendor_payment_admin? ? PurchaseOrderStatus.id_for(:auto_approved) : PurchaseOrderStatus.id_for(:approved))
    # self.purchase_order.purchase_order_status_id = status

    # unless self.purchase_order.save
    #   add_message :error, 'Unable to reopen purchase order. Please contact customer support.'
    # end

    params[:document] = self.purchase_order
    params[:aasm_event] = 'reopen'
    params[:violation_present] = false #todo Check violations
    op = WorkflowManager::Base.(user, params)
    unless op.success?
      # add_message :error, op.messages[:error]
      add_message :error, 'Unable to reopen purchase order'
      return
    end
    self.workflow_output = op.workflow_output

  end

  def post_process
    # todo-olx
    # role_id = self.workflow_output[:role_id]
    # Event::EPurchaseOrder::Retract.(user, purchase_order: purchase_order, workflow_output: workflow_output)
    add_message :success, 'Successfully Reopened Purchase Order'
    rollback_purchase_request_items
    rollback_purchase_request_status
  end

  def rollback_purchase_request_items
    if self.purchase_order.purchase_request_items.present?
      purchase_order.purchase_request_items.where(status_id: PurchaseRequestItemStatus.id_for(:po_closed)).update_all(status_id: PurchaseRequestItemStatus.id_for(:po_approved))
    end
  end

  def rollback_purchase_request_status
    if purchase_order.purchase_request_items.present?
      self.purchase_order.purchase_request_items.each do |purchase_request_item|
        purchase_request = purchase_request_item.purchase_request
        params[:document] = purchase_request
        params[:violation_present] = false
        if purchase_request.purchase_request_items.where(status_id: [PurchaseRequestItemStatus.id_for(:po_closed), PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.
          id_for(:rejected)]).present?
          # Partially Close
          unless purchase_request.partially_closed?
            params[:aasm_event] = 'partially_close'
            op = WorkflowManager::Base.(user, params)
            unless op.success?
              add_message :error, "Cannot partially close associated purchase request #{purchase_request.order_number} at this state"
            end
          end
        else
          # Approved
          unless purchase_request.approved? || purchase_request.auto_approved?
            purchase_request.update(purchase_request_status_id: PurchaseRequestStatus.id_for(:approved))
            Trail.create(parent_type: 'PurchaseRequest', parent_id: purchase_request.id, action_user_id: user.id, action_id: TrailAction.id_for(:po_reopen))
            # Needs current level which is not present here
            # params[:aasm_event] = 'approve'
            # op = WorkflowManager::Base.(user, params)
            # unless op.success?
            #   add_message :error, "Cannot approve associated purchase request #{purchase_request.order_number} at this state"
            # end
          end
        end
      end
    end
  end


end