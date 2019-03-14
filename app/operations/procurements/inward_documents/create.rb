class Procurements::InwardDocuments::Create < Procurements::InwardDocuments::Base
  attr_accessor :inward_document, :procurement, :inward_document_params, :purchase_order, :inward_document_create_params
  def init
    procurement_id = params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: procurement_id
    # self.inward_document_params = inward_document_parameters
    self.purchase_order = self.procurement&.purchase_order
    self.inward_document_create_params = create_inward_document_params
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found for this procurement, cannot create inward document'
    end

    if self.purchase_order.closed?
      add_message :error, "This Purchase Order is closed. No further actions can be taken."
    end
  end

  def process
    self.inward_document = self.procurement.inward_documents.build inward_document_create_params
    inward_document.save

    # Create Trail for Inward Document
    inward_document.trails.create action_user_id: user.id,
                                  action_id: ::TrailAction.id_for(:create)

    for item in purchase_order.items
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
        previously_delivered: po_item.delivered,
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

