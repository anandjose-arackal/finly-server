# Update any detail to purchase order LINKED to a procurement
# This operation is called AFTER a new procurement is created and the corresponding purcose order is created and,
# the page is redirected to show the purchase order for any updation of details, like adding advance payments to it


class Procurements::PurchaseOrders::Update < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params, :po_old_attachments,
                :po_current_attachments, :document_reviewer_mappings_params, :document_number,
                :vendor

  def init
    self.purchase_order_params = purchase_order_parameters
    # self.procurement = user.company.procurements.find_by params[:procurement_id]
    purchase_order_id = params[:id] || params[:purchase_order_id]
    # self.purchase_order = PurchaseOrder.find_by id: purchase_order_id
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.document_reviewer_mappings_params = params[:document_reviewer_mappings]
    purchase_order_params.delete(:document_reviewer_mappings)

    self.document_number = purchase_order_params[:po_number]
    purchase_order_params.delete(:po_number)

    vendor_id = params[:purchase_order][:vendor_id]
    self.vendor = ::BankTransfer::Vendors::Index.(user, {without_bank_accounts: true}).vendors.with_ids(vendor_id).first rescue nil
  end

  def validate
    if purchase_order.approved? || purchase_order.auto_approved?
      add_message :error, "Cant update Purchase Orders which are already approved"
    end

    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end

    unless self.purchase_order_params[:policy_id].present?
      if self.purchase_order.policy.blank?
        add_message :error, 'Policy cannot be blank'
      end
    end
  end

  def pre_process
    self.po_current_attachments = user.company.procurement_attachments.with_id(purchase_order_params[:attachments])

    self.purchase_order_params.delete(:attachments)

    #old attachments
    self.po_old_attachments = self.purchase_order.attachments
  end

  def process

    puts "PURCHASEORDER UPDATE FROM Process", params.inspect
    # binding.pry
    # binding.pry
    # self.purchase_order = procurement.build_purchse_order(purchase_order_params)
    # advance_amount_attributes: [:value, :currency_id]
    purchase_order_params[:advance_amount_attributes] = {value: 300, currency_id: 1}
    purchase_order_params[:due_date] = "2019-02-22"
    purchase_order_params[:advance_amount_status_id] = AdvanceAmountStatus.id_for(:to_be_processed)
    puts "PURCHASEORDER AFTER ADVANCE UPDATE FROM Process", params.inspect
    puts "purchase_order_params", purchase_order_params.inspect
    puts "purchase_order before", purchase_order.inspect
    purchase_order.assign_attributes(purchase_order_params)
    puts "purchase_order after", purchase_order.inspect
    # binding.pry
    if purchase_order.valid?

      purchase_order.save
      # binding.pry
      purchase_order.save

      if PurchaseOrder.status_ids(:open, :retracted, :rejected).include?(purchase_order.purchase_order_status_id) && purchase_order.user_id == user.id
        # For setting level specific reviewers from reviewal chain for a document
        params[:reviewal_document] = self.purchase_order.reload
        params[:document_reviewer_mappings] = document_reviewer_mappings_params

        document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Set.(user, params)
        unless document_reviewer_mappings_op.success?
          add_message :error, document_reviewer_mappings_op.messages[:error]
          return
        end
      end

      # Save Custom Fields
      if params[:custom_fields].present?
        CustomField::SetFields.(purchase_order, FieldParentType.id_for(:purchase_order), custom_fields: params[:custom_fields], save: true, reset_fields: true)
      end

      unless purchase_order.user == user
        # If updated by anyone other document owner
        purchase_order.trails.create action_user: user,
                                     action_id: TrailAction.id_for(:update),
                                     action_level: purchase_order.trails.last.action_level
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
