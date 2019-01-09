class Procurements::PurchaseOrders::Update < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params, :po_old_attachments,
                :po_current_attachments, :document_reviewer_mappings_params, :document_number

  def init
    self.purchase_order_params = purchase_order_parameters
    # self.procurement = user.company.procurements.find_by params[:procurement_id]
    purchase_order_id = params[:id] || params[:purchase_order_id]
    # self.purchase_order = PurchaseOrder.find_by id: purchase_order_id
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.document_reviewer_mappings_params = purchase_order_params[:document_reviewer_mappings]
    purchase_order_params.delete(:document_reviewer_mappings)

    self.document_number = purchase_order_params[:po_number]
    purchase_order_params.delete(:po_number)
  end

  def validate
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
    # self.purchase_order = procurement.build_purchse_order(purchase_order_params)
    purchase_order.assign_attributes(purchase_order_params)
    if purchase_order.valid?

      # For setting level specific reviewers from reviewal chain for a document
      params[:reviewal_document] = self.purchase_order
      params[:document_reviewer_mappings] = document_reviewer_mappings_params

      document_reviewer_mappings_op = ::ReviewalManager::DocumentReviewalMappings::Create.(user, params)
      unless document_reviewer_mappings_op.success?
        add_message :error, document_reviewer_mappings_op.messages[:error]
        return
      end

      purchase_order.save
      purchase_order.save

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