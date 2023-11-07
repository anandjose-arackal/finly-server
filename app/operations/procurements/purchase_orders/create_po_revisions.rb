# This operations helps in creating revisions of original purchase orders
# this is done only if the po is marked as sent to vendor
# 
class Procurements::PurchaseOrders::CreatePoRevisions < Procurements::PurchaseOrders::Base

  attr_accessor :purchase_order, :procurement, :klass, :foreign_keys, :duplicate_po, :original_purchase_order

  def init
    id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by(id: id)
    self.procurement = self.purchase_order.procurement
    self.original_purchase_order = self.procurement.purchase_order
    self.klass = PurchaseOrder.reflect_on_all_associations(:has_many).map(&:name)
    self.klass.delete(:dlrms)
    self.klass.delete(:dlrm_with_level)
    self.klass.delete(:trails)
    self.klass.delete(:advance_payments)
    self.klass.delete(:payments)
    self.klass.delete(:purchase_request_items)
    # self.foreign_keys = klass.map {|k| PurchaseOrder.reflections[k.to_s].foreign_key}
  end


  def validate
    if self.purchase_order.blank?
      add_message :error, "Purchase order not found"
    end
    if self.procurement.po_revisions.pluck(:revision_of_id).include? params[:purchase_order_id].to_i
      add_message :error, "Revision for this Purchase Order already exist."
    end
  end


  def process
    # self.duplicate_po = PurchaseOrder.new(self.purchase_order.attributes.merge({po_number: nil, id: nil}))

    self.duplicate_po = self.purchase_order.dup
    self.duplicate_po.revised_po_id = self.purchase_order.procurement_id
    self.duplicate_po.revision_of_id = self.purchase_order.id
    self.duplicate_po.revision_number = self.purchase_order.revision_number + 1
    self.duplicate_po.po_number = nil
    self.duplicate_po.controlling_level_id = nil
    # also setting the approved_at and submitted_at attributes to nil because the PO will be submitted again and approved
    self.duplicate_po.approved_at = nil
    self.duplicate_po.submitted_at = nil
    # self.duplicate_po.advance_amount_status_id = nil
    self.duplicate_po.advance_amount_status_id = self.purchase_order.advance_payments.present? ? self.purchase_order.advance_amount_status_id : AdvanceAmountStatus.id_for(:to_be_processed)
    self.duplicate_po.purchase_order_status_id = (user.vendor_payment_admin? && !document_owner?? PurchaseOrderStatus.id_for(:auto_approved) : PurchaseOrderStatus.id_for(:open))
    # op = Procurements::DocumentNumbers::Generate.(user, {document: self.duplicate_po})
    # if op.success?
    #   self.duplicate_po.po_number = op.document_number
    # end
    self.purchase_order.paper_trail_event = "PO Revised"
    self.duplicate_po.paper_trail_event = "PO Revised"
    self.purchase_order.update(purchase_order_status_id: PurchaseOrderStatus.id_for(:po_revised))

    self.purchase_order.trails.create action_user: user, action_id: TrailAction.id_for(:revision), note: "Revised PO generated, ##{self.duplicate_po.po_number}"
    if self.duplicate_po.save
      if self.purchase_order.purchase_request_items.present?
        update_purchase_request_item
      end

      # moving the advance payments along with the revised PO update
      # changed the update_all to an update because callbacks need to be triggered for the
      # payment object that will update the paid amount in the new, revised PO

    end

    self.klass.each_with_index do |k, kid| 
      obj = self.purchase_order.__send__(k)
      next if k == :line_items
      next if k == :attachments


      if obj.present?
        # self.duplicate_po.__send__("#{k}=", self.purchase_order.__send__(k))
        obj.each do |po|
          if k == :form_custom_fields
            custom_field = FormCustomField.new(po.dup.attributes.except([:id, :uuid]))
            custom_field[:document_id] = self.duplicate_po.id
            obj.where(entity_type: 'attachment').each do |entity|
              custom_field.attachments += entity.attachments
            end
            self.duplicate_po.form_custom_fields << custom_field
            next
          end
          self.duplicate_po.__send__(k) << po.dup
          
          if k == :quotations
            self.duplicate_po.quotations.last.attachments << po.attachments.collect { |attach| attach.dup }
          end
        end

        if k == :document_level_reviewer_mappings
          dlrms_attr = {taken_control:false, taken_control_by_id: nil, viewable: false, action_taken_by_id: nil, action_id: nil}
          self.duplicate_po.document_level_reviewer_mappings.each {|dlrm| dlrm.assign_attributes(dlrms_attr)}
        end

      end

    end

    # important to keep this line to preserve calculated values
    self.duplicate_po.process_line_item_calculation

    if self.duplicate_po.save
      # self.original_purchase_order.trails.create action_user: user, action_id: TrailAction.id_for(:revision), note: "Revised PO generated, ##{self.duplicate_po.po_number}"
      self.duplicate_po.trails.create action_user: user, action_id: TrailAction.id_for(:create), note: "Revised PO created from, ##{self.purchase_order.po_number}"
      #re-use the same blobs
      self.purchase_order.attachments.update_all(procurement_document_id: duplicate_po.id)

      # Update procurement po approved status tags
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_approved))
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_processing))
      self.procurement.status_tags.delete(old_status_tag)
      self.procurement.status_tags << status_tag

      # Update procurement send status
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:po_sent))
      if self.procurement.status_tags.include? status_tag
        self.procurement.status_tags.delete(status_tag)
      end

    else
      add_message :error, self.duplicate_po.errors.full_messages
    end

  end

  def post_process
    # here we are also taking the advance payments and explcitily triggering the callbacks because
    # it seems to not be happening when we update the parents to the new PO
    if self.purchase_order.advance_payments.present?
        self.purchase_order.advance_payments.update(parent_id: self.duplicate_po.id, purchase_order_id: self.duplicate_po.id)
    end

    self.duplicate_po.advance_payments.each do |payment|
      payment.save
    end
    add_message :success, 'Successfully generated a revised purchase order.'
  end

  def success
    params[:duplicate_po] = self.duplicate_po
    Procurements::PurchaseOrders::CreatePoRevisions::PaymentsPresenter.new(user, params, messages)
  end

  private

  def document_owner?
    self.purchase_order.user_id.eql?(user.id)
  end

  class Procurements::PurchaseOrders::CreatePoRevisions::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :duplicate_po

    def init
      self.duplicate_po = params[:duplicate_po]
    end

  end

  def update_purchase_request_item
    if purchase_order.purchase_request_items.present?
      self.purchase_order.purchase_request_items.each do |item|
        purchase_request = item.purchase_request
        item.update(purchase_order_id: duplicate_po.id, status_id: PurchaseRequestItemStatus.id_for(:po_created))
        Trail.create(parent_type: 'PurchaseRequestItem', parent_id: item.id, action_user_id: user.id, action_id: TrailAction.id_for(:po_revised))
        update_purchase_request_status(purchase_request)
      end
    end
  end

end
