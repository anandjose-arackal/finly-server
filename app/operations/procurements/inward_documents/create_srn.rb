class Procurements::InwardDocuments::CreateSrn < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :procurement, :inward_document_params, :purchase_order, :inward_document_create_params, :po_revision, :inward_document,
                :rejected_items, :non_goods_items, :accepted_items, :grn_enabled, :grn_disabled, :srn_enabled, :srn_disabled
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    self.purchase_order = self.procurement&.purchase_order

    if self.procurement.po_revisions.present?
      self.po_revision = self.procurement.po_revisions.last
      if po_revision.present?
        self.purchase_order = self.po_revision
      end
    end
    self.inward_document_create_params = create_inward_document_params


    if self.procurement.inward_documents.present?
      self.inward_document = self.procurement.inward_documents.last
    end

  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement. Cannot create Receipt Note'
    end

    if self.purchase_order.processing? || self.purchase_order.open?
      add_message :error, "This Purchase Order is not yet approved. Cannot create Receipt Note"
    end

    if self.purchase_order.closed?
      add_message :error, "This Purchase Order is closed. No further actions can be taken."
    end

    if self.purchase_order.voided?
      add_message :error, "This Purchase Order is voided. No further actions can be taken."
    end

    if all_items_accepted?(self.purchase_order)
      add_message :error, "Cannot add new Receipt Note if previous Receipt Note has all items shipped."
    end


    self.rejected_items = []
    self.accepted_items = []

    if self.procurement.inward_documents.present?
      self.inward_document.items.each do |item|
        if item.order_amount.to_f != ( item.previously_billed_amount.to_f + item.billable_amount.to_f )
          accepted_items << item.purchase_order_item_id
        end
      end
    end


    self.non_goods_items = purchase_order.items.map {|item| item if item.inventory_line_item.product_type_id != ProductType.id_for(:goods) }.compact

    if self.non_goods_items.blank?
      add_message :error, "Receipt Note can only be added for services and not for goods."
      return
    end
    validate_role
  end

  def process
    self.inward_document = self.procurement.inward_documents.build inward_document_create_params
    inward_document.save

    # Create Trail for Inward Document
    inward_document.trails.create action_user_id: user.id,
                                  action_id: ::TrailAction.id_for(:create)

    for item in purchase_order.items
      next if self.accepted_items.present? && !self.accepted_items.include?(item.id) # if accepted_items does not include the random po item, skip
      next if ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
      inward_item_params = inward_document_item_params(item)
      inward_document_item = inward_document.items.build(inward_item_params)
      inward_document_item.save
    end

  end

  def post_process
    # Update Status Tags for Procurement
    #   Find if all items are shipped
    if all_items_shipped?(self.purchase_order)
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:receiving_shipment))
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:shipment_received))
      self.procurement.status_tags.delete(old_status_tag)
      self.procurement.status_tags << status_tag
    else
      status_tag = StatusTag.find_by(id: StatusTag.id_for(:receiving_shipment))
      old_status_tag = StatusTag.find_by(id: StatusTag.id_for(:shipment_received))
      self.procurement.status_tags.delete(old_status_tag)
      self.procurement.status_tags << status_tag
    end
  end

  def success
    params[:inward_document] = self.inward_document
    Procurements::InwardDocuments::CreateSrn::CreatePresenter.new(user, params, messages)
  end

  class Procurements::InwardDocuments::CreateSrn::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :inward_document, :items

    def init
      self.inward_document = params[:inward_document]
      self.items = inward_document.items
    end
  end

  private

  def inward_document_item_params(po_item)
    #params
    inward_item_params = {
        purchase_order_item_id: po_item.id,
        inventory_line_item_id: po_item.inventory_line_item_id,
        product_id: po_item.product_id,
        description: po_item.description,
        quantity: po_item.quantity,
        previously_billed_amount: po_item.previously_billed_amount,
        order_amount: po_item.taxable_amount&.value,
        billable_amount: 0,
        product_type_id: po_item.inventory_line_item.product_type_id
    }
  end

  def create_inward_document_params
    {
        company_id: procurement.company.id,
        vendor_id: purchase_order&.vendor&.id,
        user: user
    }

  end

  def validate_role
    unless user.is_goods_receiver? || user.vendor_payments_admin?
      add_message :error, 'You are not allowed to create this document'
      return
    end
  end

  def all_items_shipped?(po)
    configuration = user.company.feature_subscription

    self.grn_enabled = configuration.grn_enabled == true
    self.grn_disabled = configuration.grn_enabled == false

    self.srn_enabled = configuration.srn_enabled == true
    self.srn_disabled = configuration.srn_enabled == false

    shipped = true
    
    if self.grn_enabled && self.srn_disabled
      po.items.each do |item|
        next if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
        unless item.quantity == item.accepted
          shipped = false
          break
        end
      end
    elsif self.grn_disabled && self.srn_enabled
      po.items.each do |item|
        next if ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
        unless item.previously_billed_amount.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
          shipped = false
          break
        end
      end
    elsif self.grn_enabled && self.srn_enabled
      po.items.each do |item|
        case item.inventory_line_item.product_type_id
        when ProductType.id_for(:goods)
          unless item.quantity == item.accepted
            shipped = false
            break
          end
        when ProductType.id_for(:service)
          unless item.previously_billed_amount.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
            shipped = false
            break
          end
        end
      end
    end
    shipped
  end

  def all_items_accepted?(po)
    configuration = user.company.feature_subscription

    self.grn_enabled = configuration.grn_enabled == true
    self.grn_disabled = configuration.grn_enabled == false

    self.srn_enabled = configuration.srn_enabled == true
    self.srn_disabled = configuration.srn_enabled == false

    shipped = true
    
    if self.grn_enabled && self.srn_disabled
      po.items.each do |item|
        next if ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
        unless item.quantity == (item.accepted + 0)
          shipped = false
          break
        end
      end
    elsif self.grn_disabled && self.srn_enabled
      po.items.each do |item|
        next if ( item.inventory_line_item.product_type_id == ProductType.id_for(:goods) )
        unless item.previously_billed_amount.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
          shipped = false
          break
        end
      end
    elsif self.grn_enabled && self.srn_enabled
      po.items.each do |item|
        case item.inventory_line_item.product_type_id
        when ProductType.id_for(:service)
          unless item.previously_billed_amount.to_f.round(2) == item.taxable_amount&.value.to_f.round(2)
            shipped = false
            break
          end
        when ProductType.id_for(:goods)
          unless item.quantity == (item.accepted + 0)
            shipped = false
            break
          end
        end
      end
    end
    shipped
  end

end

