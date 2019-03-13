# Update any detail to purchase order LINKED to a procurement
# This operation is called AFTER a new procurement is created and the corresponding purcose order is created and,
# the page is redirected to show the purchase order for any updation of details, like adding advance payments to it


class Procurements::PurchaseOrders::Update < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params, :po_old_attachments,
                :po_current_attachments, :document_reviewer_mappings_params, :document_number,
                :vendor, :procurement, :bank_account, :original_purchase_order

 def init
    self.purchase_order_params = purchase_order_parameters
    # self.procurement = user.company.procurements.find_by params[:procurement_id]
    purchase_order_id = params[:id] || params[:purchase_order_id]
    # self.purchase_order = PurchaseOrder.find_by id: purchase_order_id
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id

    # params[:bank_account_id] = '80'
    if purchase_order_params[:bank_account_id]
      self.bank_account = self.purchase_order&.vendor&.bank_accounts&.find_by(id: purchase_order_params[:bank_account_id]) rescue nil
    end

    self.procurement = self.purchase_order.procurement
    self.original_purchase_order = self.procurement.purchase_order
    self.document_reviewer_mappings_params = params[:document_reviewer_mappings]
    purchase_order_params.delete(:document_reviewer_mappings)

    self.document_number = purchase_order_params[:po_number]
    purchase_order_params.delete(:po_number)

    vendor_id = params[:purchase_order][:vendor_id]
    self.vendor = ::BankTransfer::Vendors::Index.(user, {without_bank_accounts: true}).vendors.with_ids(vendor_id).first rescue nil
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
      return
    end

    if (purchase_order.approved? || purchase_order.auto_approved? || purchase_order.sent_to_vendor?) && !user.vendor_payment_admin?
      add_message :error, "Cant update Purchase Orders which are already approved or marked as 'sent to vendor'"
    end

    if self.procurement.po_revisions.pluck(:revision_of_id).include? self.purchase_order.id
      add_message :error, 'Revision for this purchase order found. Original purchase order can no longer be modified. Check trails.'
      return
    end

    unless self.purchase_order_params[:policy_id].present?
      if self.purchase_order.policy.blank?
        add_message :error, 'Policy not found.'
      end
    end

    # if self.purchase_order.procurement.invoices.present? && self.purchase_order.procurement.inward_documents.present?
    #   add_message :error, "Can't modify a purchase order which has a GRN or Invoice attached."
    # end

    # need to recheck this logic
    unless self.purchase_order.updatable? || user.vendor_payment_admin?
      add_message :error, "Can't modify a purchase order which has a GRN or Invoice attached."
    end

    if self.bank_account.blank?
      add_message :error, 'Please select the bank account of the vendor.'
      return
    end

    # unless self.purchase_order_params[:advance_amount_attributes].blank?  && self.purchase_order_params[:advance_amount_attributes][:value].blank? && self.bank_account.blank?
    #   valid = true
    #   Rails.logger.fatal purchase_order_params.inspect
    #   Rails.logger.fatal params.inspect
    #     add_message :error, 'Bro you have chosen to add advance amount but it is empty.'
    #     valid = false

    #   elsif self.purchase_order_params[:due_date].blank?
    #     add_message :error, 'Bro add the due date for the advance bro.'
    #     valid = false

    #   elsif self.bank_account.blank?
    #     add_message :error, 'Please select the bank account of the vendor.'
    #     valid = false

    #   end

    #   if valid && purchase_order.advance_amount_status_empty
    #     purchase_order_params[:advance_amount_status_id] = AdvanceAmountStatus.id_for(:to_be_processed)
    #   end
    # end

    if self.purchase_order_params[:advance_amount_attributes][:value].present? && self.purchase_order_params[:advance_amount_attributes][:value].to_f > 0
      if self.purchase_order_params[:due_date].blank?
        add_message :error, 'Due date for the advance amount has not been set.'
      end
      valid_date = Date.parse(self.purchase_order_params[:due_date]) rescue false 
      unless valid_date
        add_message :error, 'Invalid date provided'
        return
      end
      unless (Date.parse(self.purchase_order_params[:due_date]) >= Date.today)
        add_message :error, 'Cannot create back dated payment tickets'
      end
    else
      self.purchase_order_params[:due_date] = nil
    end    

  end

  def pre_process
    self.po_current_attachments = user.company.procurement_attachments.with_id(purchase_order_params[:attachments])

    self.purchase_order_params.delete(:attachments)

    #old attachments
    self.po_old_attachments = self.purchase_order.attachments


    if self.purchase_order_params[:advance_amount_attributes][:value].present?
      purchase_order_params[:advance_amount_attributes][:id] = self.purchase_order&.advance_amount&.id
      # purchase_order_params[:advance_amount_status_id] = AdvanceAmountStatus.id_for(:to_be_processed)
    else
      self.purchase_order_params[:advance_amount_attributes][:value] = self.purchase_order&.advance_amount&.value
    end
  end

  def process

    # self.purchase_order = procurement.build_purchse_order(purchase_order_params)
    # advance_amount_attributes: [:value, :currency_id]
    # purchase_order_params[:advance_amount_attributes] = {value: 300, currency_id: 1}
    # purchase_order_params[:due_date] = "2019-02-22"
    # purchase_order_params[:advance_amount_status_id] = AdvanceAmountStatus.id_for(:to_be_processed)

    purchase_order.assign_attributes(purchase_order_params)

    if purchase_order.valid?

      purchase_order.save
      purchase_order.save
      # purchase_order.process_line_item_calculation

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

      if self.purchase_order.purchase_order_status_id == PurchaseOrderStatus.id_for(:open)
        document_number_op = Procurements::DocumentNumbers::Generate.(user, {document: self.purchase_order})

        if document_number_op.success?
          self.purchase_order.update(po_number: document_number_op.document_number)
        end
      end

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
end
