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
    self.klass.delete(:trails)
    self.klass.delete(:advance_payments)
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
    self.duplicate_po.purchase_order_status_id = (user.vendor_payment_admin? ? PurchaseOrderStatus.id_for(:auto_approved) : PurchaseOrderStatus.id_for(:open))

    op = Procurements::DocumentNumbers::Generate.(user, {document: self.duplicate_po})
    if op.success?
      self.duplicate_po.po_number = op.document_number
    end

    self.duplicate_po.save

    self.klass.each_with_index do |k, kid| 
      obj = self.purchase_order.__send__(k)

      if obj.present?
        # self.duplicate_po.__send__("#{k}=", self.purchase_order.__send__(k))
        self.purchase_order.__send__(k).each do |po|
          self.duplicate_po.__send__(k) << po.dup
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
      self.original_purchase_order.trails.create action_user: user, action_id: TrailAction.id_for(:revision), note: "Revised PO generated, ##{self.duplicate_po.po_number}"
      self.purchase_order.trails.create action_user: user, action_id: TrailAction.id_for(:revision)
      self.duplicate_po.trails.create action_user: user, action_id: TrailAction.id_for(:create)
    else
      add_message :error, self.duplicate_po.errors.full_messages
    end

  end

  def post_process
    add_message :success, 'Successfully generated a revised purchase order.'
  end

  def success
    params[:duplicate_po] = self.duplicate_po
    Procurements::PurchaseOrders::CreatePoRevisions::PaymentsPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::CreatePoRevisions::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :duplicate_po

    def init
      self.duplicate_po = params[:duplicate_po]
    end

  end

end
