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
      add_message :error, "Can't modify a purchase order which has a GRN or Invoice attached."
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

    if StringUtils.to_bool( self.purchase_order_params[:advance_amount_required] ) 
      unless self.purchase_order_params[:requested_advance_amount_attributes][:value].to_f > 0
        add_message :error, "You selected advance to be added for this PO. Please add advance amount."
        return
      end
    end


    if self.purchase_order_params[:requested_advance_amount_attributes][:value].present? && self.purchase_order_params[:requested_advance_amount_attributes][:value].to_f > 0
      if self.purchase_order_params[:requested_advance_amount_attributes][:value].to_i > params[:purchase_order][:total_after_tax_attributes][:value].to_i
        add_message :error, "Advance amount can't be more than Total amount"
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
    # Validate if user has access to PO show page    
    validate_document_access
    # Validate if user has access to PO update
    validate_association
  end

  def pre_process
    # update gstin location id
    if self.gstin_location.present?
      self.purchase_order_params[:gstin_location_id] = self.gstin_location&.id
    end

    self.po_current_attachments = user.company.procurement_attachments.with_id(purchase_order_params[:attachments])

    self.purchase_order_params.delete(:attachments)

    #old attachments
    self.po_old_attachments = self.purchase_order.attachments

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

  def process

    
    purchase_order.assign_attributes(purchase_order_params)
    if purchase_order.valid?

      # Set validation of DLRMs
      if PurchaseOrder.status_ids(:open, :retracted, :rejected).include?(purchase_order.purchase_order_status_id) && purchase_order.user_id == user.id

        dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::ValidationUpdate.(user, {
          reviewal_document: self.purchase_order,
          document_reviewer_mappings_params: document_reviewer_mappings_params
        })

        unless dlrm_validation_op.success?
          add_message :error, dlrm_validation_op.messages[:error]
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

      purchase_order.save
      purchase_order.process_line_item_calculation(self.skip_adv_calculation)
      purchase_order.save

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

    self.po_old_attachments.update_all(procurement_document_id: nil, procurement_document_type: nil)

    self.po_current_attachments.update_all(procurement_document_id: purchase_order.id, procurement_document_type: purchase_order.class.name)
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

end
