# Update any detail to purchase order LINKED to a procurement
# This operation is called AFTER a new procurement is created and the corresponding purcose order is created and,
# the page is redirected to show the purchase order for any updation of details, like adding advance payments to it


class Procurements::PurchaseOrders::Update < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params, :po_old_attachments,
                :po_current_attachments, :document_reviewer_mappings_params, :document_number,
                :vendor, :procurement, :bank_account, :original_purchase_order, :department, :skip_adv_calculation,
                :gstin_location, :cost_allocation_items, :policy

  def init
    self.purchase_order_params = purchase_order_parameters
    # self.procurement = user.company.procurements.find_by params[:procurement_id]
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id

    if purchase_order_params[:bank_account_id]
      self.bank_account = self.purchase_order&.vendor&.bank_accounts&.find_by(id: purchase_order_params[:bank_account_id]) rescue nil
    end

    # if purchase_order_params[:gstin_location_id].present?
    self.gstin_location = self.purchase_order&.vendor&.gstin_locations.find_by(id: purchase_order_params[:gstin_location_id]) || self.purchase_order.vendor&.gstin_locations.first
    # end

    self.procurement = self.purchase_order.procurement
    self.original_purchase_order = self.procurement.purchase_order
    self.document_reviewer_mappings_params = params[:document_reviewer_mappings]
    purchase_order_params.delete(:document_reviewer_mappings)

    self.document_number = purchase_order_params[:po_number]
    purchase_order_params.delete(:po_number)

    vendor_id = params[:purchase_order][:vendor_id]
    self.vendor = ::BankTransfer::Vendors::Index.(user, {without_bank_accounts: true}).vendors.with_ids(vendor_id).first rescue nil

    self.department = user.company.departments.find_by(id: purchase_order_params[:department_id])

    # Check if department and cost center are to be saved globally for the po or individually for each item
    self.cost_allocation_items = StringUtils.to_bool(self.purchase_order_params[:cost_allocation_items])

    self.policy = Policy::VendorPayments::Index.(current_user, params).policies.find_by(id: purchase_order_params[:policy_id])

    fetch_budget_contributions(purchase_order)
  end

  def validate
    return if record_not_present
    if purchase_order.sent_to_vendor? || purchase_order.vendor_confirmed?
      # add_message :error, "Cant update purchase order marked as 'sent to vendor'"
      add_message :error, "Cant update purchase order marked as '#{purchase_order.status.name.humanize.downcase}'"
      return
    end

    if (purchase_order.approved? || purchase_order.auto_approved?) && !user.vp_admin_or_auditor?
      add_message :error, "Cant update Purchase Orders which are already approved or marked as 'sent to vendor'"
    end

    if self.procurement.po_revisions.pluck(:revision_of_id).include? self.purchase_order.id
      add_message :error, 'Revision for this purchase order found. Original purchase order can no longer be modified. Check trails.'
      return
    end

    # unless self.purchase_order_params[:policy_id].present?
    #   if self.purchase_order.policy.blank?
    #     add_message :error, 'Policy not found.'
    #   end
    # end

    if self.policy.blank? && self.purchase_order.policy.blank?
      add_message :error, 'Please select a policy'
    end

    if self.purchase_order_params[:delivery_date].blank?
      add_message :error, "Please add an expected delivery date for the Purchase Order, i.e., when do you expect all added items to be delivered."
      return
    end

    if self.purchase_order_params[:location_id].blank?
      add_message :error, "Please specify a Billing Address."
    end

    if self.purchase_order_params[:delivery_location_id].blank?
      add_message :error, "Please specify a Shipping Address."
      return
    end


    if self.purchase_order.quotations.present?
      quotes = self.purchase_order.quotations
      selected_quotes = quotes.map { |q| q if q.selected }.compact
      if selected_quotes.count > 1
        add_message :error, "Please select atmost one quotation"
        return
      end

      if selected_quotes.blank?
        add_message :error, "Please select atleast one quotation"
        return
      end
    end

    if self.purchase_order_params[:delivery_date].present?
      valid_date = Date.parse(self.purchase_order_params[:delivery_date]) rescue false 
      unless valid_date
          add_message :error, 'Invalid date provided'
          return
      end

      unless Date.parse(self.purchase_order_params[:delivery_date]) && (Date.parse(self.purchase_order_params[:delivery_date]) >= Date.today)
        add_message :error, 'Delivery Date can only be set to a present or future date.'
        return
      end
    end

    if self.department.blank? && !self.cost_allocation_items
      add_message :error, "Please select a department"
    end

    if self.purchase_order.procurement.invoices.present? && self.purchase_order.procurement.inward_documents.present?
      add_message :error, "Can't modify a purchase order which has a Receipt Note or Invoice attached."
    end

    # need to recheck this logic
    # unless self.purchase_order.updatable? # || user.vendor_payment_admin?
    #   add_message :error, "Can't modify a purchase order which has a GRN or Invoice attached."
    # end

    if self.bank_account.blank?
      add_message :error, 'Please select the bank account of the vendor.'
      return
    end

    # Removing hard check for department and cc line item wise

    # if self.cost_allocation_items
    #   arr = self.purchase_order_params[:items_attributes].pluck(:department_id)

    #   if arr.collect {|a| a.blank? }.include? true
    #     add_message :error, "Please select a Department for which the item would be purchased."
    #     return
    #   end

    #   arr = self.purchase_order_params[:items_attributes].pluck(:cost_center_id)


    #   if arr.collect {|a| a.blank? }.include? true
    #     add_message :error, "Please select a Cost Center for which the item would be purchased."
    #     return
    #   end
    # else
    #   self.purchase_order_params[:items_attributes].each do |item|
    #     item[:department_id] = self.purchase_order_params[:department_id]
    #     item[:cost_center_id] = self.purchase_order_params[:cost_center_id]
    #   end
    # end

    unless self.cost_allocation_items
      self.purchase_order_params[:items_attributes].each do |item|
        item[:department_id] = self.purchase_order_params[:department_id]
        item[:cost_center_id] = self.purchase_order_params[:cost_center_id]
      end
    end

    # if procurements already has advance payments, disallow editing advance amount even if po revised.
    if purchase_order.advance_payments.present?
      self.purchase_order_params.delete(:advance_tds_slab_id)
      self.purchase_order_params.delete(:advance_amount_required)
      self.purchase_order_params.delete(:advance_amount_attributes)
      self.purchase_order_params.delete(:requested_advance_amount_attributes)
    else
      validation_for_advance_amount
    end

    # Validate if user has access to PO show page    
    validate_document_access
    # Validate if user has access to PO update
    validate_association

    # docon does not new items to be added in a po if created from pr
    if [203, 2].include?(self.purchase_order.company_id) && (self.purchase_order.items.pluck(:purchase_request_item_id).compact.present?)
      if purchase_order_params[:items_attributes].pluck(:id, :_destroy).any? {|id, des| (id == "" || id == nil) && !!StringUtils.to_bool(des) == false}
        add_message :error, "New items cannot be added if this PO was created from PR."
        return
      end
      items = purchase_order_params[:items_attributes].select {|pa| pa if pa[:id].present? && !pa[:_destroy]}
      if items.count != self.purchase_order.items.count
        add_message :error, "Existing items in the PO, which came from PR, cannot be deleted."
        return
      end

      item_hash = self.purchase_order.items.pluck(:id, :quantity).to_h
      purchase_order_params[:items_attributes].each do |item|
        next if item[:_destroy]
        if item[:quantity].to_i != item_hash[item[:id].to_i]
          add_message :error, "Quantity should remain the same if this PO was created from PR."
          return
        end
      end
    end
  end

  def pre_process
    # update gstin location id
    if purchase_order_params[:gst_type_id].blank?
      if self.gstin_location.present?
        self.purchase_order_params[:gstin_location_id] = self.gstin_location&.id

        # check against the shipping location sent in the params
        shipping_location = user.company.locations.find_by(id: params[:shipping_location_id])
        if self.gstin_location.state_code == shipping_location&.state_code
          self.purchase_order_params[:gst_type_id] = GstType.id_for(:cgst_sgst)
        else
          self.purchase_order_params[:gst_type_id] = GstType.id_for(:igst)
        end
      else
        self.purchase_order_params[:gst_type_id] = GstType.id_for(:igst)
      end
    end
    if self.gstin_location.present?
      self.purchase_order_params[:gstin_location_id] = self.gstin_location&.id
    end

    self.po_current_attachments = user.company.procurement_attachments.with_id(purchase_order_params[:attachments])

    self.purchase_order_params.delete(:attachments)

    #old attachments
    self.po_old_attachments = self.purchase_order.attachments

    # if procurements already has advance payments, disallow editing advance amount even if po revised.
    if purchase_order.advance_payments.present?
      self.purchase_order_params.delete(:advance_tds_slab_id)
      self.purchase_order_params.delete(:advance_amount_required)
      self.purchase_order_params.delete(:advance_amount_attributes)
      self.purchase_order_params.delete(:requested_advance_amount_attributes)
    else
      pre_process_for_advance_amount
    end

  end

  def process
    # begin
    ActiveRecord::Base.transaction(requires_new: true) do
      purchase_order.assign_attributes(purchase_order_params)
      if purchase_order.valid?
        update_purchase_request_item_status
        # Set validation of DLRMs
        if PurchaseOrder.status_ids(:open, :retracted, :rejected).include?(purchase_order.purchase_order_status_id) && purchase_order.user_id == user.id

          dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::ValidationUpdate.(user, {
              reviewal_document: self.purchase_order,
              document_reviewer_mappings_params: document_reviewer_mappings_params
          })
          unless dlrm_validation_op.success?
            add_message :error, dlrm_validation_op.messages[:error]
            raise ActiveRecord::Rollback, dlrm_validation_op.messages[:error]
            return
          end
        end

        # if PurchaseOrder.status_ids(:open, :retracted, :rejected).include?(purchase_order.purchase_order_status_id) && purchase_order.user_id == user.id
        #   # For setting level specific reviewers from reviewal chain for a document
        #   params[:reviewal_document] = self.purchase_order
        #   params[:document_reviewer_mappings] = document_reviewer_mappings_params

        #   document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
        #   unless document_reviewer_mappings_op.success?
        #     add_message :error, document_reviewer_mappings_op.messages[:error]
        #     return
        #   end
        # end

        unless purchase_order.save
          raise ActiveRecord::Rollback, 'Unable to save'
        end
        purchase_order.process_line_item_calculation(self.skip_adv_calculation)
        unless purchase_order.save
          raise ActiveRecord::Rollback, 'Unable to save'
        end

        # Directly update the columns because we have callbacks,
        # and those callbacks are validating data which were not previously formatted, like ifsc, (we have some gibberrish ifsc values which  were allowed to be saved before)
        # so at this moment it is better to simply call the database,
        # later when we have proper formatted data, we will call update
        # if params[:bank_account_id]
        #   self.bank_account.update_columns(purchase_order_id: purchase_order.id)
        # end

        if PurchaseOrder.status_ids(:open, :retracted, :rejected).include?(purchase_order.purchase_order_status_id) && purchase_order.user_id == user.id
          # For setting level specific reviewers from reviewal chain for a document
          params[:reviewal_document] = self.purchase_order
          params[:document_reviewer_mappings] = document_reviewer_mappings_params

          document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
          unless document_reviewer_mappings_op.success?
            add_message :error, document_reviewer_mappings_op.messages[:error]
            raise ActiveRecord::Rollback, document_reviewer_mappings_op.messages[:error]
            return
          end
        end

        # purchase_order.save
        # purchase_order.save

        # Save Custom Fields
        if params[:custom_fields].present?
          CustomField::SetFields.(purchase_order, FieldParentType.id_for(:purchase_order), custom_fields: params[:custom_fields], save: true, reset_fields: true)
        end

        unless purchase_order.user == user
          # If updated by anyone other document owner
          purchase_order.trails.create action_user: user,
                                       action_id: TrailAction.id_for(:update),
                                       action_level: purchase_order.trails.last.action_level


          # if self.procurement.po_revisions
          #   self.original_purchase_order.trails.create action_user: user,
          #                              action_id: TrailAction.id_for(:update),
          #                              action_level: purchase_order.trails.last.action_level,
          #                              note: "Revised PO # #{purchase_order.po_number} updated"
          # end
        end

        # Create track

        # if self.purchase_order.purchase_order_status_id == PurchaseOrderStatus.id_for(:open)
        #   document_number_op = Procurements::DocumentNumbers::Generate.(user, {document: self.purchase_order})
        #
        #   if document_number_op.success?
        #     self.purchase_order.update(po_number: document_number_op.document_number)
        #   end
        # end

        # AS OF NOW MULTIPLE ADVANCE PAYMENT CREATION CANCELLED
        # TO BE TAKEN UP LATER

        # params[:purchase_order_id] = self.purchase_order.id
        # params[:receiving_user_type] = self.vendor.class&.name
        # params[:receiving_user_id] = self.vendor.bank_accounts.first.account_owner_id # MODIFY TO ADD ANY BANK ACCOUNT
        # params[:receiving_account_id] = self.vendor.id

        # params[:advance_payments_attributes] = [ { scheduled_at: "2019-02-06", amount_attributes: { id: 292688, value: 200} }, { amount_attributes: { id: 292689, value: 300} } ]
        # params[:advance_payments_attributes] = [ { scheduled_at: "2019-02-06", amount_attributes: { value: 200} }, { amount_attributes: { value: 300} } ]

        # unless params[:advance_payments_attributes].blank?
        #   op = Procurements::Payments::AddAdvance.(user, params)
        #   if op.success?
        #     add_message :success, 'Successfully added advance payment to this purchase order'
        #   else
        #     add_message :error, op.messages[:error]
        #   end
        # end

      else
        add_message :error, purchase_order.errors.full_messages
        return
      end
      # rescue => e
      #   add_message :error, messages
      # end

      self.po_old_attachments.update_all(procurement_document_id: nil, procurement_document_type: nil)

      self.po_current_attachments.update_all(procurement_document_id: purchase_order.id, procurement_document_type: purchase_order.class.name)

      return if has_errors?

      # Budget check
      budget_validation_op = budget_limit_validation(purchase_order)
      if budget_validation_op.present? && budget_validation_op.failure? && budget_validation_op.messages[:errors].present?
        add_message :error, budget_validation_op.messages[:errors]
        raise ActiveRecord::Rollback
        return
      end
    end
  end

  def post_process
    add_message :success, 'Successfully updated purchase order'
  end

  def validate_presence
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
      return false
    end
    true
  end

  def record_not_present
    !validate_presence
  end

  def validate_document_access
    Procurements::PurchaseOrders::Show.(user, params).success?
  end

  def validate_association
    return if purchase_order.update_if_owner(user) if PurchaseOrderStatus.status_ids_for_owner.include?(purchase_order.purchase_order_status_id)
    return if purchase_order.update_if_admin(user) if !PurchaseOrderStatus.status_ids_for_owner.include?(purchase_order.purchase_order_status_id) || purchase_order.user_id.blank?
    return if purchase_order.update_if_reviewer(user) if PurchaseOrderStatus.status_ids_for_reviewer.include?(purchase_order.purchase_order_status_id)
    add_message :error, 'Unable to update'
  end

  def validation_for_advance_amount
    if StringUtils.to_bool( self.purchase_order_params[:advance_amount_required] ) 
      unless self.purchase_order_params[:requested_advance_amount_attributes][:value].to_f > 0
        add_message :error, "You selected advance to be added for this PO. Please add advance amount."
        return
      end
    end


    if self.purchase_order_params[:requested_advance_amount_attributes][:value].present? && self.purchase_order_params[:requested_advance_amount_attributes][:value].to_f > 0
      if self.purchase_order_params[:requested_advance_amount_attributes][:value].to_i > (params[:purchase_order][:balance_amount_attributes][:value].to_i + 1) # adding a buffer to account for roundoff amount
        add_message :error, "Advance amount can't be more than the Balance Due for the entire PO."
        return
      end
      if self.purchase_order_params[:due_date].blank?
        add_message :error, 'Scheduled date for the advance amount has not been set.'
        return
      end
      valid_date = Date.parse(self.purchase_order_params[:due_date]) rescue false 
      unless valid_date
        add_message :error, 'Invalid date provided'
        return
      end
      unless (Date.parse(self.purchase_order_params[:due_date]) >= Date.today)
        add_message :error, 'Cannot create back dated scheduled payments for advances.'
      end
    else
      self.purchase_order_params[:due_date] = nil
    end
  end

  def pre_process_for_advance_amount
    if self.purchase_order_params[:requested_advance_amount_attributes][:value].present?
      purchase_order_params[:requested_advance_amount_attributes][:id] = self.purchase_order&.requested_advance_amount&.id
      # purchase_order_params[:advance_amount_status_id] = AdvanceAmountStatus.id_for(:to_be_processed)
      self.skip_adv_calculation = false
      if ( purchase_order_params[:requested_advance_amount_attributes][:value].to_i == self.purchase_order.requested_advance_amount&.value ) && ( purchase_order_params[:advance_tds_slab_id].to_i == self.purchase_order.advance_tds_slab_id )
        self.skip_adv_calculation = true
      end
    else
      self.purchase_order_params[:requested_advance_amount_attributes][:value] = self.purchase_order&.requested_advance_amount&.value || 0
      self.purchase_order_params[:due_date] = self.purchase_order.due_date
      self.skip_adv_calculation = true
    end
  end

  def update_purchase_request_item_status
    if purchase_order.purchase_request_items.present?
      po_revision_ids = []
      deleted_po_item_ids = []
      deleted_po_item_pr_item_ids = []
      purchase_order.items.each do |purchase_order_item|
        purchase_request_item = purchase_order_item.purchase_request_item
        if purchase_request_item.present?
          if purchase_order_item.marked_for_destruction?
            deleted_po_item_ids << purchase_order_item.id
            deleted_po_item_pr_item_ids << purchase_order_item.purchase_request_item_id
            # If revised po line items are deleted which were created from PR line item, then all the previous PO's will not have pr line item reference to their line item. i.e., line item will be as if it was not created from PR as it will loose reference to PR
            # This is done to avoid duplicate PO for the same approved items 
            if purchase_order_item&.purchase_order&.procurement&.po_revisions&.present?
              procurement_id = purchase_order_item&.purchase_order&.procurement&.id
              # PO revision related ids
              po_revision_ids << user.company.purchase_orders.where(procurement_id: procurement_id).pluck(:id)
            end
            purchase_request_item.update_attributes(purchase_order_id: nil)
            purchase_request_item.update_attributes(status_id: PurchaseRequestItemStatus.id_for(:approved))
            user = RequestStore.store[:current_user]
            if user.present?
              Trail.create(parent_type: 'PurchaseRequestItem', parent_id: purchase_request_item.id, action_user_id: user.id, action_id: TrailAction.id_for(:po_item_deleted))
            end
          end
        end
      end
      po_revision_ids = po_revision_ids&.flatten&.compact&.uniq
      deleted_po_item_ids = deleted_po_item_ids&.flatten&.compact&.uniq
      deleted_po_item_pr_item_ids = deleted_po_item_pr_item_ids&.flatten&.uniq
      if po_revision_ids.present?
        po_revision_ids.each do |po_revision_id|
          revised_po = user.company.purchase_orders.find_by_id po_revision_id
          if revised_po.present?
            if revised_po.items.where(purchase_request_item_id: deleted_po_item_pr_item_ids).present?
              revised_po.items.where(purchase_request_item_id: deleted_po_item_pr_item_ids).each do |po_item|
                # Remove reference to PR line item so that multiple PO's cannot be raised for one approved item with PR line item reference
                po_item.update_attributes(purchase_request_item_id: nil)
              end
            end
          end
        end
      end
    end
  end

end
