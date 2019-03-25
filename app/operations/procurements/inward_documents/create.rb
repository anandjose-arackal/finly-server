class Procurements::InwardDocuments::Create < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :procurement, :inward_document_params, :purchase_order, :inward_document_create_params, :po_revision, :inward_document,
                :rejected_items, :non_service_items
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    # self.inward_document_params = inward_document_parameters
    self.purchase_order = self.procurement&.purchase_order

    if self.procurement.po_revisions.present?
      # self.po_revision = self.procurement.po_revisions.find_by(id: params[:po_id])
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
      add_message :error, 'Purchase Order not found for this procurement, cannot create GRN'
    end

    if self.purchase_order.closed?
      add_message :error, "This Purchase Order is closed. No further actions can be taken."
    end

    if self.purchase_order.all_items_accepted?
      add_message :error, "Cant add new GRN if previous GRN has all items shipped."
    end


    self.rejected_items = []

    # if self.procurement.inward_documents.present?
    #   inv_items = self.procurement.inward_documents.includes(:items)
    #   self.inward_document.items.each do |item|
    #     item_q = inv_items.map { |iv| iv.items.where(inventory_line_item_id: item.inventory_line_item_id) }.flatten
    #     if self.inward_document.items.pluck(:accepted).first < item_q.first.quantity
    #       add_message :error, "Items in GRN cant be lower than items in Invoice"
    #       break
    #     end
    #   end
    # end


    if self.procurement.inward_documents.present?
      self.inward_document.items.each do |item|
        if item.quantity == ( item.previously_delivered || ( item.accepted + item.rejected ) )
          rejected_items << item.purchase_order_item_id
        end
      end
    end

    self.non_service_items = purchase_order.items.map {|item| item if item.inventory_line_item.product_type_id != ProductType.id_for(:service) }.compact

    if self.non_service_items.blank?
      add_message :error, "GRN can only be added for goods and not for services."
      return
    end

  end

  def process
    self.inward_document = self.procurement.inward_documents.build inward_document_create_params
    inward_document.save

    # Create Trail for Inward Document
    inward_document.trails.create action_user_id: user.id,
                                  action_id: ::TrailAction.id_for(:create)

    for item in purchase_order.items
      next if self.rejected_items.include?(item.id) || ( item.inventory_line_item.product_type_id == ProductType.id_for(:service) )
      inward_item_params = inward_document_item_params(item)
      inward_document_item = inward_document.items.build(inward_item_params)
      inward_document_item.save
    end

  end

  def post_process
    # Update Status Tags for Procurement
    #   Find if all items are shipped
    if self.purchase_order.all_items_shipped?
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
    Procurements::InwardDocuments::Create::CreatePresenter.new(user, params, messages)
  end

  class Procurements::InwardDocuments::Create::CreatePresenter < BaseOperation::BasePresenter::SuccessPresenter
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
        previously_delivered: po_item.accepted,
        delivered: 0,
        accepted: 0,
        rejected: 0
    }
  end

  def create_inward_document_params
    {
        company_id: procurement.company.id,
        vendor_id: purchase_order&.vendor&.id,
        user: user
    }

  end
end

