class Procurements::PurchaseOrders::Base < BaseOperation
  attr_accessor :workflow_output
  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def purchase_order_parameters
    params.require(:purchase_order).permit(
        :id, :location_id, :delivery_location_id, :procurement_id, :vendor_id, :payment_term_id, :sub_department_id, :cost_center_id, :note,
        :procurement_term_id, :indent_number, :indent_date, :override_po_number, :policy_id, :department_id,
        :billing_address, :shipping_address, :vendor_address,  :cost_allocation_items, :shipping_location_id, :billing_location_id, :vendor_location_id,
        :delivery_date, :gst_type_id, :inclusive_of_taxes, :roundoff_total_enabled, :roundoff_amount, :procurement_term_text, :due_date, :advance_tds_slab_id, :advance_amount_required, :bank_account_id,
        :gstin_location_id, :cost_allocation_items, :internal_note, :vendor_poc_name, :vendor_poc_email, :vendor_poc_mobile_number, :discount_type_id,
        items_attributes: [
            :id, :department_id, :cost_center_id, :unit_of_measurement, :_destroy, :product_id, :description, :hsn_sac, :quantity, :rate, :tax, :tax_rate_id, :tds, :discount, :delivery_date, :comment,
            :inventory_line_item_id, :category_id
        ],
        attachments: [],
        document_reviewer_mappings: [
            :level_id, :reviewer_id
        ],
        # advance_payments_attributes: [:id, :scheduled_at, amount_attributes: [:id, :value, :currency_id]]
        # advance_payments_attributes: [:id, :scheduled_at, amount_attributes: [:id, :value, :currency_id]],
        # document_reviewer_mappings: [:level_id, :reviewer_id]
        tax_amount_attributes: [:value, :currency_id],
        advance_amount_attributes: [:value, :currency_id],
        purchase_request_item_attributes: [:id, :purchase_order_id],
        requested_advance_amount_attributes: [:value, :currency_id]
        # advance_payment_attributes: [:advance_amount],
        # document_reviewer_mappings: [:level_id, :reviewer_id]
        # tax_amount_attributes: [:value, :currency_id]
        # purchase_request_items_attributes: [
        #     :id, :item_id, :required_by_date, :purpose, :delivery_location_id, :quantity, :vendor_id, :_destroy, per_unit_estimated_amount_attributes: [:id, :value, :currency_id, :_destroy]
        # ]
    )
  end

  def update_purchase_request_status(purchase_request = nil)
    if purchase_request.present?
      if purchase_request.purchase_request_items.where(status_id: [PurchaseRequestItemStatus.id_for(:po_closed), PurchaseRequestItemStatus.id_for(:issued_from_inventory), PurchaseRequestItemStatus.
          id_for(:rejected)]).present?
        # Partially Close
        unless purchase_request.partially_closed?
          params[:aasm_event] = 'partially_close'
          params[:document] = purchase_request
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

  def budget_limit_validation purchase_order
    if user.company.feature_subscription.enforce_budget_limit
      op = BudgetManager::BudgetLimitValidator::ValidatePurchaseOrder.(user, { purchase_order: purchase_order })
      if op.messages[:error].present?
        return add_message :error, op.messages[:error]
      end
    end    
  end
end

